#!/usr/bin/env bash

# file downloader
downloadFile () {
   # check whether URL path was given; return error if not
   if [ -z "$1" ]; then
      echo "No URL path given to download. Exiting."
      exit 1
   else
      urlPath="$1"
   fi
   # check whether file name was given; return error if not
   if [ -z "$2" ]; then
      echo "No file name given to download. Exiting."
      exit 1
   else
      filename="$2"
   fi

   # check whether file is downloaded and fully cached
   file_is_cached=false
   if [ -f $filename ]; then
      # get remote filesize
      remote_filesize=$(curl -sI $urlPath/$filename | grep Content-Length | awk '{print $2}')
      remote_filesize_no_whitespace="$(echo -e "${remote_filesize}" | tr -d '[[:space:]]')"
      local_filesize=$(ls -l "$filename" | awk '{print $5}')

      # compare file sizes
      if [ "$remote_filesize_no_whitespace" = "$local_filesize" ]; then
         file_is_cached=true
      fi
   fi

   if [[ "$file_is_cached" = false ]]; then
      echo "Downloading $filename..."
      curl -O -C - $urlPath/$filename

      if [ $? -ne 0 ]; then
         echo "Unable to download from $urlPath/$filename"
         exit 1
      fi
   else
      echo "File '$filename' already cached. Skipping..."
   fi
}
