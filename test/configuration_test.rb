require_relative 'helper'

describe Recaptcha::Configuration do
  describe "#logger" do
    before do
      @logger = mock('STDOUT')
    end

    it "is nil" do
      assert_nil Recaptcha.configuration.logger
    end

    it "is a Logger class" do
      Recaptcha.with_configuration(logger: @logger) do
        Recaptcha.configuration.logger.must_equal @logger
      end
    end

    it "has a logger" do
      Recaptcha.with_configuration(logger: @logger) do
        Recaptcha.configuration.logger?.must_equal true
      end
    end

    it "does not have a logger" do
      Recaptcha.configuration.logger?.must_equal false
    end
  end

  describe "#logger_tags" do
    it "has default logger tags" do
      Recaptcha.configuration.logger_tags.must_equal(event: "recaptcha-response")
    end

    it "has overwritten logger tags" do
      tags = { foo: 'bar' }
      Recaptcha.configuration.logger_tags = tags
      begin
        Recaptcha.configuration.logger_tags.must_equal tags
      ensure
        Recaptcha.configuration.logger_tags = nil
      end
    end
  end

  describe "#api_server_url" do
    it "serves the default (free API)" do
      Recaptcha.configuration.api_server_url.must_equal "https://www.recaptcha.net/recaptcha/api.js"
    end

    describe "when enterprise is set to true" do
      it "serves the enterprise API URL" do
        Recaptcha.with_configuration(enterprise: true) do
          Recaptcha.configuration.api_server_url.must_equal "https://www.recaptcha.net/recaptcha/enterprise.js"
        end
      end
    end

    describe "when api_server_url is overwritten" do
      it "serves the overwritten url" do
        proxied_api_server_url = 'https://127.0.0.1:8080/recaptcha/api.js'
        Recaptcha.configuration.api_server_url = proxied_api_server_url
        begin
          Recaptcha.configuration.api_server_url.must_equal proxied_api_server_url
        ensure
          Recaptcha.configuration.api_server_url = nil
        end
      end
    end
  end

  describe "#verify_url" do
    it "serves the default" do
      Recaptcha.configuration.verify_url.must_equal "https://www.recaptcha.net/recaptcha/api/siteverify"
    end

    describe "when api_server_url is overwritten" do
      it "serves the overwritten url" do
        proxied_verify_url = 'https://127.0.0.1:8080/recaptcha/api/siteverify'
        Recaptcha.configuration.verify_url = proxied_verify_url
        begin
          Recaptcha.configuration.verify_url.must_equal proxied_verify_url
        ensure
          Recaptcha.configuration.verify_url = nil
        end
      end
    end
  end

  it "can overwrite configuration in a block" do
    outside = '0000000000000000000000000000000000000000'
    Recaptcha.configuration.site_key.must_equal outside

    Recaptcha.with_configuration(site_key: '12345') do
      Recaptcha.configuration.site_key.must_equal '12345'
    end

    Recaptcha.configuration.site_key.must_equal outside
  end

  it "cleans up block configuration after block raises an exception" do
    before = Recaptcha.configuration.site_key.dup

    assert_raises NoMemoryError do
      Recaptcha.with_configuration(site_key: '12345') do
        Recaptcha.configuration.site_key.must_equal '12345'
        raise NoMemoryError, "an exception"
      end
    end

    Recaptcha.configuration.site_key.must_equal before
  end
end
