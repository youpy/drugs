# -*- coding: utf-8 -*-
require 'sinatra'
require './lib/names.rb'

helpers do
  def name(digest)
    @name ||= Names.new(digest).generate
  end

  def title(digest)
    Names.new(digest).title
  end

  def url(digest)
    Names.new(digest).url
  end
end

get '/' do
  haml :'/'
end

post '/' do
  url = params[:url]
  xpath = params[:xpath]

  names = Names.create_from_url_and_xpath(url, xpath)
  redirect '/%s/' % names.digest
end

get '/:digest/' do
  @digest = params[:digest]

  haml :'/digest/'
end

get '/:digest/json' do
  content_type 'text/json'
  JSON.pretty_generate(name: name(params[:digest]))
end

__END__
@@ /
!!! 5
%html
  %head
    %title Markov Chain Generator
    %link{rel:'stylesheet',href:'bootstrap.min.css'}
    :css
      .jumbotron { background-color: white }
  %body
    %div.jumbotron
      %div.container
        %h1 Markov Chain Generator
        %form{role:"form",method:"post",action:"/"}
          %div.form-group
            %label{for:"url"} URL
            %input.form-control{type:"url",name:"url",placeholder:"Enter URL"}
          %div.form-group
            %label{for:"xpath"} XPath
            %input.form-control{type:"text",name:"xpath",placeholder:"Enter XPath"}
          %input.btn.btn-default{type:"submit",value:"Submit"}
    %div.container
      %p
        based on
        %a{href:'http://drugs.herokuapp.com/'} 医薬品一覧 - Wikipedia のマルコフ連鎖

@@ /digest/
!!! 5
%html
  %head
    %title= name(@digest)
    %link{rel:'stylesheet',href:'../bootstrap.min.css'}
    :css
      .jumbotron { background-color: white }
      * { color: red }
  %body
    %div.jumbotron
      %a{href: url(@digest)}= title(@digest)
      のマルコフ連鎖
      (
      %a{href: "./json"} JSON
      )
      %a.twitter-share-button.pull-right{"href"=>"https://twitter.com/share"} Tweet
      %hr
      %h1.text-center= name(@digest)
      :javascript
        !function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');

