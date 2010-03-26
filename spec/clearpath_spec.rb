require 'spec_helper'

describe Clearpath do
  before(:all) do
    FakeWeb.register_uri(
      :get,
      'https://ews2.cpmvp.net/Login/',
      :body => fakeweb_template('login.html'),
      :content_type => 'text/html'
    )
    FakeWeb.register_uri(
      :post,
      'https://ews2.cpmvp.net/servlet/Login',
      :status => [302, 'Found'],
      :location => 'https://ews2.cpmvp.net/Common/folder_contents.jsp?menuId=1'
    )
    FakeWeb.register_uri(
      :get,
      'https://ews2.cpmvp.net/Common/folder_contents.jsp?menuId=1',
      :body => fakeweb_template('profile.html'),
      :content_type => 'text/html'
    )
    FakeWeb.register_uri(
      :get,
      'https://ews2.cpmvp.net/Group/Hunt_Group/',
      :body => fakeweb_template('hunt_groups.html'),
      :content_type => 'text/html'
    )
    FakeWeb.register_uri(
      :get,
      'https://ews2.cpmvp.net/Group/Hunt_Group/Modify/index.jsp?key=2127928644%40cpmvp.net',
      :body => fakeweb_template('hunt_group_form.html'),
      :content_type => 'text/html'
    )
    FakeWeb.register_uri(
      :post,
      'https://ews2.cpmvp.net/Group/Hunt_Group/Modify/index.jsp?key=2127928644%40cpmvp.net',
      :status => [302, 'Found'],
      :location => 'https://ews2.cpmvp.net/Common/folder_contents.jsp?folder=U0&menuId=0'
    )
    FakeWeb.register_uri(
      :get,
      'https://ews2.cpmvp.net/Common/folder_contents.jsp?folder=U0&menuId=0',
      :body => fakeweb_template('hunt_group.html'),
      :content_type => 'text/html'
    )
  end

  before(:each) do
    @clearpath = Clearpath.new('username', 'password')
  end

  context "#set_forward_delay" do
    it "raises if an invalid mode is specified" do
      lambda {
        @clearpath.set_forward_delay('Theater Hunt', :weekend)
      }.should raise_error(ArgumentError, 'Invalid mode.')
    end

    it "sets the forward delay for day mode" do
      @clearpath.set_forward_delay('Theater Hunt', :day)
    end

    it "sets the forward delay for night mode" do
      @clearpath.set_forward_delay('Theater Hunt', :night)
    end
  end

  after(:all) do
    FakeWeb.clean_registry
  end
end
