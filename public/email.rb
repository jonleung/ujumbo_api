# encoding: UTF-8

require 'nokogiri'
require 'debugger'

s1 = %{
  <div dir="ltr">
    HAI
  </div>
  <div class="gmail_extra">
    <br>
    <br>
    <div class="gmail_quote">
      On Tue, Apr 16, 2013 at 2:16 PM,  
      <span dir="ltr">
        &lt;
        <a href="mailto:hello@ujumbo.com" target="_blank">
          hello@ujumbo.com
        </a>
        &gt;
      </span>
      wrote:
      <br>
      
      <blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
        Response Body
      </blockquote>
    </div>
    <br>
  </div>
}

s2 = %{
  <div dir="ltr">
    Lolol, that is hilarious!
    <div>
      <br>
    </div>
    <div>
      Alright, sounds good to me!
    </div>
    <div>
      <br>
    </div>
    <div>
      <span style="font-family:arial,sans-serif;font-size:13px">
        Talk to you later!
      </span>
      <div class="" style="font-family:arial,sans-serif;font-size:13px">
        
      </div>
    </div>
  </div>
  <div class="gmail_extra">
    <br>
    <br>
    <div class="gmail_quote">
      On Tue, Apr 16, 2013 at 6:15 PM, Jonathan 
      <span dir="ltr">
        &lt;
        <a href="mailto:naruto137@gmail.com" target="_blank">
          naruto137@gmail.com
        </a>
        &gt;
      </span>
      wrote:
      <br>
      
      <blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
        <div dir="ltr">
          Lolol, that is hilarious!
          <div>
            <br>
          </div>
          <div>
            Alright, sounds good to me!
          </div>
          <div>
            <br>
          </div>
          <div>
            Talk to you later!
            <span class="HOEnZb">
              <font color="#888888">
                <br>
                
                Jonathan
              </font>
            </span>
          </div>
        </div>
        <div class="HOEnZb">
          <div class="h5">
            <div class="gmail_extra">
              <br>
              <br>
              <div class="gmail_quote">
                On Tue, Apr 16, 2013 at 6:14 PM,  
                <span dir="ltr">
                  &lt;
                  <a href="mailto:hello@ujumbo.com" target="_blank">
                    hello@ujumbo.com
                  </a>
                  &gt;
                </span>
                wrote:
                <br>
                <blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
                  
                  
                  Hi, what is going on? This is going to be super cool! 
                  <br>
                  
                  <h1>
                    Funtimes
                  </h1>
                  <br>
                  <br>
                </blockquote>
              </div>
              <br>
            </div>
          </div>
        </div>
      </blockquote>
    </div>
    <br>
  </div>
}

s3 = %{
  <html>
  <head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8">
  </head>
  <body dir="auto">
  <div>
    This is being sent from an iPhone!!
  </div>
  <div>
    <br>
  </div>
  <div>
    Whatip!<br>
    <br>
    <div>
      <div style="text-align: left; ">
        <div>
          <font color="#191919" face="Georgia"><span style="line-height: 23px; -webkit-tap-highlight-color: rgba(26, 26, 26, 0.292969); -webkit-composition-fill-color: rgba(175, 192, 227, 0.230469); -webkit-composition-frame-color: rgba(77, 128, 180, 0.230469);">—</span></font>
        </div>
        <div>
          <font color="#191919" face="Georgia"><span style="line-height: 23px; -webkit-tap-highlight-color: rgba(26, 26, 26, 0.292969); -webkit-composition-fill-color: rgba(175, 192, 227, 0.230469); -webkit-composition-frame-color: rgba(77, 128, 180, 0.230469);">Sent from my mobile–apologies for brevity and any typos</span></font>
        </div>
        <div>
          <font color="#191919" face="Georgia"><span style="line-height: 23px; -webkit-tap-highlight-color: rgba(26, 26, 26, 0.292969); -webkit-composition-fill-color: rgba(175, 192, 227, 0.230469); -webkit-composition-frame-color: rgba(77, 128, 180, 0.230469);"><br>
          </span></font>
        </div>
        <div>
          <font color="#191919" face="Georgia"><span style="line-height: 23px; -webkit-tap-highlight-color: rgba(26, 26, 26, 0.292969); -webkit-composition-fill-color: rgba(175, 192, 227, 0.230469); -webkit-composition-frame-color: rgba(77, 128, 180, 0.230469);"><a href="http://jonl.org">jonl.org</a> | 610-761-0083</span></font>
        </div>
      </div>
    </div>
  </div>
  <div>
    <br>
    On Apr 16, 2013, at 6:19 PM, <a href="mailto:hello@ujumbo.com">hello@ujumbo.com</a> wrote:<br>
    <br>
  </div>
  <div>
    Hi, what is going on? This is going to be super cool! <br>
    <h1>Funtimes</h1>
    <br>
    <br>
  </div>
  </body>
  </html>
}

d1 = Nokogiri::HTML(s1)
d1.search('blockquote').remove
 
debugger