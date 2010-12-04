require 'spec_helper.rb'

describe Rack::OAuth2::Server::Authorize::Code do

  context "when authorized" do

    before do
      @app = Rack::OAuth2::Server::Authorize.new(simple_app) do |request, response|
        response.approve!
        response.code = "authorization_code"
      end
      @request = Rack::MockRequest.new @app
    end

    it "should redirect to redirect_uri with authorization code" do
      response = @request.get("/?response_type=code&client_id=client&redirect_uri=http://client.example.com/callback")
      response.status.should == 302
      response.location.should == "http://client.example.com/callback?code=authorization_code"
    end

    context "when redirect_uri already includes query" do
      it "should keep original query" do
        response = @request.get("/?response_type=code&client_id=client&redirect_uri=http://client.example.com/callback?k=v")
        response.status.should == 302
        response.location.should == "http://client.example.com/callback?k=v&code=authorization_code"
      end
    end

  end

  context "when denied" do

    before do
      @app = Rack::OAuth2::Server::Authorize.new(simple_app) do |request, response|
        request.access_denied! 'User rejected the requested access.'
      end
      @request = Rack::MockRequest.new @app
    end

    it "should redirect to redirect_uri with error message" do
      response = @request.get("/?response_type=code&client_id=client&redirect_uri=http://client.example.com/callback")
      response.status.should == 302
      error_message = {
        :error => :access_denied,
        :error_description => "User rejected the requested access."
      }
      response.location.should == "http://client.example.com/callback?#{error_message.to_query}"
    end

  end

end