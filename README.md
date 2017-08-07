NGINX RTMP Dockerfile
=====================

Based on this repo [https://github.com/brocaar/nginx-rtmp-dockerfile](https://github.com/brocaar/nginx-rtmp-dockerfile).

This Dockerfile installs NGINX configured with `nginx-rtmp-module`, ffmpeg
and some default settings for HLS live streaming.

How to use
----------

1. Build and run the container (`docker build -t nginx_rtmp .` &
   `docker run -d -p 8080:8080 -p 1935:1935 nginx_rtmp`).

2. Stream your live content to `rtmp://localhost:1935/hls/stream_name` where
   `stream_name` is the name of your stream. E.g. broadcasting an avi file:
```
ffmpeg -loglevel verbose -re -i movie.avi  -vcodec libx264 \
      -vprofile baseline -acodec libmp3lame -ar 44100 -ac 1 \
      -f flv rtmp://localhost:1935/hls/movie
```

3. In Safari, VLC or any HLS compatible browser / player, open
   `http://localhost:8080/hls/stream_name.m3u8`. Note that the first time,
   it might take a few (10-15) seconds before the stream works. This is because
   when you start streaming to the server, it needs to generate the first
   segments and the related playlists.

HLS in HTML:

```
<body>
  <video width="640" height="480" controls autoplay
         src="http://localhost:8080/hls/stream_name.m3u8">
  </video>
</body>
```

MPEG-DASH in HTML using the dash.js player:

```
<script src="http://cdn.dashjs.org/latest/dash.all.min.js"></script>

<body>
  <video data-dashjs-player
         width="640" height="480" controls autoplay
         src="http://localhost:8080/hls/stream_name.m3u8">
  </video>
</body>
```


Links
-----

* http://nginx.org/
* https://github.com/arut/nginx-rtmp-module
* https://www.ffmpeg.org/
* https://obsproject.com/
* https://github.com/brocaar/nginx-rtmp-dockerfile
