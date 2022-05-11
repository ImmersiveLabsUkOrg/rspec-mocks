# typed: true

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'sorbet'
  gem 'sorbet-runtime'
  gem 'rspec', '3.11'
  gem 'rspec-mocks', path: "./"
end

class Blog
  def initialize(id)
    @id = id
  end
  def comment_ids
    DiscussionDomain.comment_ids_for_blog(@id)
  end
end

class DiscussionDomain
  extend T::Sig

  sig {params(blog_id: Integer).returns(T::Array[Integer])}
  def self.comment_ids_for_blog(blog_id)
    [123, 456]
  end
end

RSpec.describe Blog do
  it "delegates comment_ids to DiscussionDomain" do
    blog = Blog.new("1")
    # I want this to raise, via sorbet-runtime
    # Parameter 'blog_id': Expected type Integer, got type String with value "1"
    expect(DiscussionDomain).to receive(:comment_ids_for_blog).with("1").and_return([2])
    blog.comment_ids
  end

  it "delegates comment_ids to DiscussionDomain 2" do
    blog = Blog.new(1)
    # I want this to raise, via sorbet-runtime
    # Return value: Expected type Array[Integer], got type Array[String] with value ["2"]
    expect(DiscussionDomain).to receive(:comment_ids_for_blog).with(1).and_return(["2"])
    blog.comment_ids
  end
end

RSpec::Core::Runner.autorun
