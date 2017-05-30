# Feedbooks covers


<img src="https://github.com/mgiraldo/feedbooks-covers/raw/master/output1.png" width="170"> <img src="https://github.com/mgiraldo/feedbooks-covers/raw/master/output9.png" width="170"> <img src="https://github.com/mgiraldo/feedbooks-covers/raw/master/output3.png" width="170"> <img src="https://github.com/mgiraldo/feedbooks-covers/raw/master/output5.png" width="170"> <img src="https://github.com/mgiraldo/feedbooks-covers/raw/master/output6.png" width="170">
<img src="https://github.com/mgiraldo/feedbooks-covers/raw/master/output10.png" width="170"> <img src="https://github.com/mgiraldo/feedbooks-covers/raw/master/output2.png" width="170"> <img src="https://github.com/mgiraldo/feedbooks-covers/raw/master/output4.png" width="170"> <img src="https://github.com/mgiraldo/feedbooks-covers/raw/master/output7.png" width="170"> <img src="https://github.com/mgiraldo/feedbooks-covers/raw/master/output8.png" width="170">

A generative book cover based on some feedbooks.com public domain data

Built with [Processing 3](//processing.org)

## Keyboard controls:

- `A` or `SPACEBAR` starts/stops auto refresh (step thru every book)
- `←` or `↑` goes to previous book
- `→` or `↓`  goes to next book
- `R` or `S` saves the current book in the output folder
- `M` toggles mass record (activated with auto refresh)
- `D` shows debug info in the cover (included on save)

## How to mass-produce covers

Based on the [included JSON file](data/feedbooks.json):

1. Install [Processing](https://processing.org/download/) (tested on version 3 only)
2. Open and Run the `feedbook_covers.pde`
3. Tap the **M** key to activate mass record
4. Tap the **SPACEBAR** key to activate auto refresh (you might want to decrease `refresh_rate` to make it faster)
5. Check the `output/` folder
6. Profit!

_Note, repeated ids: 15, 29, 654, 816, 874, 1072, 1174, 1326, 1492, 1505, 1549, 1957, 2677, 2872, 2898, 3005, 3274, 3520, 3673, 3687, 3696, 3723, 3765, 3803, 3877, 3976, 4081, 4411, 4544, 4878, 4910, 4939, 4976, 6626, 6648, 6648, 6660_

## License

See [LICENSE](LICENSE).
