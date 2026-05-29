# eiskaltdcpp-docker

Docker image for [eiskaltdcpp client](https://github.com/eiskaltdcpp/eiskaltdcpp) using [icecult webUI](https://github.com/eiskaltdcpp/icecult)

# command

```
docker run --rm
 -v /path/to/data:/data
 -v /path/to/downloads:/Downloads
 -v /path/to/share1:/Share/share1
 -p 8008:80
   kraiz/icecold
```

# ports
* `80` is the webinterface for you to open in browser

# volumes
* `/data/`, config and temp data folder. Add 2 files manually before starting:
  * `DCPlusPlus.xml`:
  ```
  <?xml version="1.0" encoding="utf-8" standalone="yes"?>
  <DCPlusPlus>
    <Settings>
     <Nick type="string">MYNICK</Nick>
     <DownloadDirectory type="string">/Downloads/</DownloadDirectory>
     <MaxDownloadSpeedMain type="int">0</MaxDownloadSpeedMain>
     <MaxUploadSpeedMain type="int">0</MaxUploadSpeedMain>
    </Settings>
    <Share>
      <Directory Virtual="share">/Share/</Directory>
    </Share>
  </DCPlusPlus>

  ```
  * `Favorites.xml`:
  ```
  <?xml version="1.0" encoding="utf-8" standalone="yes"?>
  <Favorites>
    <Hubs>
      <Hub Name="muhub" Connect="1" Nick="<MYNICK>" Password="" Server="adc://<HUBIP>:<HUBPORT>" />
    </Hubs>
    <Users/>
    <UserCommands/>
    <FavoriteDirs/>
  </Favorites>
  ```
* `/Share/`, mount anything you want to share below this folder.
* `/Downloads/`, a place where to store the files you downloaded. Should match directories of `DCPlusPlus.xml`.
