##functions

## making thumbnail from an image 

makethumbnail <- function(theimage, status= "draft", title= " ", size_thumb =250) {
  if (class (status) != "character") status = "draft"
  #set color code for status:
  colorstatus = ifelse(status == "draft", "red", "blue")
  colorstatus = ifelse(status == "Published", "yellow", colorstatus)
  colorstatus
  
  background = image_graph(width = size_thumb, height = size_thumb, bg = "white",
                           pointsize = 12, res = 72, clip = TRUE, antialias = TRUE)
  plot.new()
  dev.off()
  #background
  
  
  a= theimage
  ainfo= image_info(a)
  
  if (ainfo$width < ainfo$height){
    b=a %>% image_scale(geometry_size_pixels(height = size_thumb))
  } else {
    b=a %>% image_scale(geometry_size_pixels(width = size_thumb))
  }
  b
  
  
  c=image_info(b)
  xoff= (size_thumb - c$width)/2
  yoff= (size_thumb - c$height)/2
  
  thumb=image_composite(background, b, offset = geometry_point(xoff, yoff))
  
  thumb= thumb %>% 
    image_annotate(status, gravity = 'southeast',
                   color = 'black',boxcolor = colorstatus)%>%
    image_annotate(title, gravity = 'north',
                   color = 'black',boxcolor = "white", size = min(20,size_thumb*2/nchar(title)))
}



write_items_toml <- function(data = allresults, filenamepath = "data/items.toml", pathtofigurefoler= "ResultGallery/figures/") {
  if (nrow(data)>0) {
    
    fileConn = file (filenamepath)
    cat("",file=filenamepath,append=FALSE)
    
    for (i in c(1:nrow(data))){
      text = "\n[[items]]"
      text = paste0 (text,  '\n ', 'title = "', data$Title [i], '"')
      text = paste0 (text,  '\n ', 'image = "',pathtofigurefoler, data$image [i], '"')
      text = paste0 (text,  '\n ', 'thumb = "',pathtofigurefoler, data$thumb [i], '"')
      text = paste0 (text,  '\n ', 'alt = "', data$alt [i], '"')
      text = paste0 (text,  '\n ', 'description = "', gsub ("\n", "---", data$description [i]), '"')
      text = paste0 (text,  '\n ', 'url = "', data$url [i], '"')
      cat(text,file=filenamepath,append=TRUE)
  }
  
  }
}


readmeta <- function (path){
  read_tsv (path, col_types = cols( .default = col_character()))
}

# updating thumbnail from a metadata file

update_thumnail <- function(metadata_file) {
  headers = readmeta(metadata_file)
  ## entered variables
  title1 = headers$Title
  status1 = headers$status
  caption =  headers$description
  url = headers$url
  imagepath = headers$image
  thumbpath = headers$thumb
  shortname = strtrim(gsub("\\s", " ", title1) , 97)
  #library (magick)
  #source("functions.r")
  
  a = image_read(paste0("static/hall-of-results_data/figures/", imagepath))
  size_thumb_here = ifelse (headers$Highlighted,500, 250)
  thumb = makethumbnail(theimage = a,
                        status = status1,
                        title = shortname, size_thumb = size_thumb_here)
  image_write(
    thumb,
    path = paste0("static/hall-of-results_data/figures/", thumbpath),
    format = "png"
  )
}


titleify <- function(character){
  #get rid of all text after the last point (.png for example)
  thetitle = sub(pattern = "(.*)\\..*$", replacement = "\\1",character)
  # get rid of special characters
  thetitle =
    tolower( gsub("[^[:alnum:]_]", " ", thetitle))
  # make a short version
  thetitle = iconv(thetitle,from ="utf8", to ="ASCII", sub= " ")
  # get rid of multiple spaces
  thetitle= stringr::str_squish(thetitle)
  #getting output
  output = c()
  output$folder = gsub("[^[:alnum:]_]", "-", abbreviate(thetitle, minlength = 8))
  
  thetitle =  gsub("[^[:alnum:]_]", "-", thetitle)
  output$file = strtrim  (thetitle, 20)
  #output
  return (output)
}