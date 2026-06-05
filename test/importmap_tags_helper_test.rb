require "test_helper"

class Importmap::ImportmapTagsHelperTest < ActionView::TestCase
  attr_reader :request

  class FakeRequest
    def initialize(nonce = nil)
      @nonce = nonce
    end

    def send_early_hints(links); end

    def content_security_policy
      Object.new if @nonce
    end

    def content_security_policy_nonce
      @nonce
    end
  end

  test "javascript_inline_importmap_tag" do
    rendered = javascript_inline_importmap_tag
    importmap = JSON.parse(rendered[%r{<script[^>]*>(.*)</script>}m, 1])

    assert_equal "https://ga.jspm.io/npm:react@18.3.1/index.js", importmap.dig("imports", "react")
    assert_equal "https://ga.jspm.io/npm:react-dom@18.3.1/client.js", importmap.dig("imports", "react-dom/client")
    assert_match %r{/assets/application-.*\.js}, importmap.dig("imports", "application")
    assert_match %r{/assets/lib/bootstrap-.*\.js}, importmap.dig("imports", "@app/bootstrap")

    application_path = importmap.dig("imports", "application")
    bootstrap_path = importmap.dig("imports", "@app/bootstrap")

    assert importmap.dig("integrity", application_path)
    assert importmap.dig("integrity", bootstrap_path)
  end

  test "javascript_importmap_module_preload_tags" do
    rendered = javascript_importmap_module_preload_tags

    assert_includes rendered, %{href="https://ga.jspm.io/npm:react@18.3.1/index.js"}
    assert_includes rendered, %{href="https://ga.jspm.io/npm:react-dom@18.3.1/client.js"}
    assert_match %r{href="/assets/application-.*\.js"[^>]*integrity=}m, rendered
    assert_match %r{href="/assets/react/components/app_shell-.*\.js"[^>]*integrity=}m, rendered
    refute_includes rendered, "module_compat"
  end

  test "tags have no nonce if CSP is not configured" do
    @request = FakeRequest.new

    assert_no_match(/nonce/, javascript_importmap_tags("application"))
  ensure
    @request = nil
  end

  test "tags have nonce if CSP is configured" do
    @request = FakeRequest.new("iyhD0Yc0W+c=")

    assert_match(/nonce="iyhD0Yc0W\+c="/, javascript_inline_importmap_tag)
    assert_match(/nonce="iyhD0Yc0W\+c="/, javascript_import_module_tag("application"))
    assert_match(/nonce="iyhD0Yc0W\+c="/, javascript_importmap_module_preload_tags)
  ensure
    @request = nil
  end

  test "using a custom importmap" do
    importmap = Importmap::Map.new
    importmap.pin "foo", preload: true
    importmap.pin "bar", preload: false
    importmap_html = javascript_importmap_tags("foo", importmap: importmap)

    assert_includes importmap_html, %{<script type="importmap" data-turbo-track="reload">}
    assert_includes importmap_html, %{"foo": "/foo.js"}
    assert_includes importmap_html, %{"bar": "/bar.js"}
    assert_includes importmap_html, %{<link rel="modulepreload" href="/foo.js">}
    refute_includes importmap_html, %{<link rel="modulepreload" href="/bar.js">}
    assert_includes importmap_html, %{<script type="module">import "foo"</script>}
  end
end
