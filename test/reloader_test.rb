require "test_helper"

class ReloaderTest < ActiveSupport::TestCase
  setup do
    @reloader = Importmap::Reloader.new
    @config = Rails.root.join("config/importmap.rb")
  end

  test "reload is triggered when importmap changes" do
    assert_changes -> { @reloader.updated? }, from: false, to: true do
      touch_config
    end
  end

  test "redraws importmap when config changes" do
    Rails.application.importmap = Importmap::Map.new.draw { pin "md5", to: "https://cdn.skypack.dev/md5" }
    assert_not_predicate @reloader, :updated?

    touch_config
    assert @reloader.execute_if_updated

    assert_includes Rails.application.importmap.packages.keys, "application"
    assert_includes Rails.application.importmap.packages.keys, "md5"
    assert_includes Rails.application.importmap.packages.keys, "controllers/goodbye_controller"
    assert_includes Rails.application.importmap.packages.keys, "channels/consumer"
  end

  private
    def touch_config
      sleep 1
      FileUtils.touch(@config)
    end
end
