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
  it "#comment_ids raises Sorbet error when mock has bad parameter type" do
    blog = Blog.new("1")

    expect(DiscussionDomain).to receive(:comment_ids_for_blog).with("1").and_return([2])

    expect { blog.comment_ids }.to raise_error(
      TypeError,
      /Parameter 'blog_id': Expected type Integer, got type String with value "1"/
    )
  end

  it "#comment_ids raises Sorbet error when mock has bad return type" do
    blog = Blog.new(1)

    expect(DiscussionDomain).to receive(:comment_ids_for_blog).with(1).and_return(["2"])

    expect { blog.comment_ids }.to raise_error(
      TypeError,
      /Parameter 'blog_id': Expected type Array[Integer], got type Array[String] with value ["2"]/
    )
  end
end

RSpec::Core::Runner.autorun
