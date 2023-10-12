### minimal script to generate a GIF with given maximum size (in MB), starting from a png sequence

Open Kdenlive and render you video using the "Images sequence" option, selecting PNG, the desired location and "%03d.png" as the name. This will generate a sequence of numbered images from the video.

Then, generate a GIF with `./easy_gif.sh /{path_to_PNGs} {maximum_size_MB} /{output_path}/{output_name}.gif`

Dependencies:
- `sudo apt install kdenlive`
- `sudo apt-get install gifsicle`
- `sudo apt-get install imagemagick`
- `sudo apt-get install pv`