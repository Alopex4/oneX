# oneX
oneX web crawler, via url to download photoes

### Motivation
Just to learn some shell script skills, so don't use these photes(Use this script download)
in business activities or Obtaining illegal benefits.
The photoes copyright all belong to 1x.com.

## Running the script

```
$ chmod +x oneX.sh
$ ./onX.sh <1x.com_url>
```

## Single photo download (specific directory or not)
Two approach here >>> 
```
$ ./onX.sh https://1x.com/photo/<photo_id> <my_dir>

OR

$ ./onX.sh <my_dir> https://1x.com/photo/<photo_id>
```

If you want to download another photo just paste a link.
You can exit this interactive by press [Q]
```
 Input URL or (Q)uit to exit: https://1x.com/photo/<photo_id>
```

Examle:
1. Single photo download 

![image](https://github.com/Alopex4/oneX/blob/master/images/single_download.png)

2. `ls` show the photo

![image](https://github.com/Alopex4/oneX/blob/master/images/single_show.png)

3. use `eog` show the photo

![image](https://github.com/Alopex4/oneX/blob/master/images/show_singe_.png)

## Batch download (specific directory or not)
If you doesn't specific the dir, all photoes will store in current path directory 1x/
Two approach here >>> 
```
$ ./onX.sh https://1x.com/member/[<member_id>|<member_name>] <my_dir>

OR

$ ./onX.sh <my_dir> https://1x.com/member/[<member_id>|<member_name>]
```

After all the photoes downloaded, the archive will pressent
```
Archive and Compress the bulk photoes? (y/N) 
```
Just choose what you neeed.

Examle
1. Bash photoes download

![image](https://github.com/Alopex4/oneX/blob/master/images/bash_%20download.png)

2. Archive and show the store position

![image](https://github.com/Alopex4/oneX/blob/master/images/bash_archive_show.png)

3. Use GUI to show the photoes

![image](https://github.com/Alopex4/oneX/blob/master/images/show_bash.png)



