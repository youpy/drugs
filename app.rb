# -*- coding: utf-8 -*-
require 'sinatra'
require 'haml'
require './lib/markov_chain.rb'

get '/' do
  haml :'/'
end

post '/' do
  url = params[:url]
  xpath = params[:xpath]

  mc = MarkovChain.create_from_url_and_xpath(url, xpath)
  redirect '/%s/' % mc.id_str
end

get '/:id_str/' do
  @mc = MarkovChain.where(id_str: params[:id_str]).first
  @text = @mc.generate

  haml :'/id_str/'
end

get '/:id_str/json' do
  content_type 'text/json'
  headers 'Access-Control-Allow-Origin' => '*'
  JSON.pretty_generate(result: MarkovChain.where(id_str: params[:id_str]).first.generate)
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

@@ /id_str/
!!! 5
%html
  %head
    %title= @text
    %link{rel:'stylesheet',href:'../bootstrap.min.css'}
    :css
      .jumbotron { background-color: white }
  %body
    %div.jumbotron
      %div.container
        %a{href: @mc.url}= @mc.title
        のマルコフ連鎖
        (
        %a{href: "./json"} JSON
        )
        %a.twitter-share-button.pull-right{"href"=>"https://twitter.com/share"} Tweet
        %hr
        %h1.text-center= @text
    %div.container
      %form{action:'/',method:'post'}
        %p.text-right
          %small
            最終更新日時:
            = @mc.updated_at
            (
            = @mc.xpath
            )
          %input{type:'hidden',name:'xpath',value:@mc.xpath}
          %input{type:'hidden',name:'url',value:@mc.url}
          %input.btn.btn-link.btn-sm{type:'submit',value:'データ更新'}
      :javascript
        !function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');
