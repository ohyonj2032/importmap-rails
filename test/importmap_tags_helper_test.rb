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
    importmap = extract_importmap_json(javascript_inline_importmap_tag)

    assert_equal "https://cdn.skypack.dev/md5", importmap.fetch("imports").fetch("md5")
    assert_equal "/rich_text.js", importmap.fetch("imports").fetch("rich_text")
    assert_equal "sha384-OLBgp1GsljhM2TJ+sbHjaiH9txEUvgdDTAzHv2P24donTt6/529l+9Ua0vFImLlb", importmap.fetch("integrity").fetch("/rich_text.js")
  end

  test "javascript_inline_importmap_tag supports shim mode" do
    assert_match(/type="importmap-shim"/, javascript_inline_importmap_tag("{}", shim: true))
  end

  test "javascript_importmap_module_preload_tags" do
    assert_dom_equal(
      %(
        <link rel="modulepreload" href="https://cdn.skypack.dev/md5">
        <link rel="modulepreload" href="/rich_text.js" integrity="sha384-OLBgp1GsljhM2TJ+sbHjaiH9txEUvgdDTAzHv2P24donTt6/529l+9Ua0vFImLlb">
      ),
      javascript_importmap_module_preload_tags
    )
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

  test "javascript_importmap_tags supports shim mode" do
    importmap_html = javascript_importmap_tags("application", shim: true)

    assert_includes importmap_html, %{<script type="importmap-shim" data-turbo-track="reload">}
    assert_includes importmap_html, %{<script type="module-shim">import "application"</script>}
  end

  private
    def extract_importmap_json(html)
      fragment = Nokogiri::HTML.fragment(html)
      JSON.parse(fragment.at_css("script").text)
    end
end