//Packages
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moviefy/models/main_page_data.dart';

//Models
import 'package:moviefy/models/movie.dart';
import 'package:moviefy/models/search_category.dart';

//Widgets
import 'package:moviefy/widgets/movie_tile.dart';

//Controller
import 'package:moviefy/controllers/main_page_data_controller.dart';

final mainPageDataControllerProvider =
    StateNotifierProvider<MainPageDataController>((ref) {
  return MainPageDataController();
});

final selectedMoviePosterURLProvider = StateProvider<String?>((ref) {
  final _movies = ref.watch(mainPageDataControllerProvider).state.movies;
  return _movies.isNotEmpty ? _movies[0].posterURL() : null;
});

class MainPage extends ConsumerWidget {
  late double _device_height;
  late double _device_width;
  late double _statusbar_height;

  late TextEditingController _searchTextFieldController;

  var _selectedMoviePosterURL;

  late MainPageDataController _mainPageDataController;
  late MainPageData _mainPageData;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    _mainPageDataController = watch(mainPageDataControllerProvider);
    _mainPageData = watch(mainPageDataControllerProvider.state);
    _selectedMoviePosterURL = watch(selectedMoviePosterURLProvider);

    _device_height = MediaQuery.of(context).size.height;
    _device_width = MediaQuery.of(context).size.width;
    _statusbar_height = MediaQuery.of(context).padding.top;

    _searchTextFieldController = TextEditingController();
    _searchTextFieldController.text = _mainPageData.searchText.toString();

    return _buildUi();
  }

  Widget _buildUi() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: _device_height,
        width: _device_width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            colors: [
              Colors.blue,
              Colors.blue.shade200,
              Colors.blue.shade400,
              Colors.blue.shade600,
              Colors.blue.shade800,
              Colors.blue.shade900,
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _backgroundWidget(),
            _foregroundWidget(),
          ],
        ),
      ),
    );
  }

  Widget _backgroundWidget() {
    if (_selectedMoviePosterURL.state != null) {
      return Container(
        height: _device_height,
        width: _device_width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(_selectedMoviePosterURL.state),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 9.0, sigmaY: 9.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: _device_height,
        width: _device_width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            colors: [
              Colors.blue,
              Colors.blue.shade200,
              Colors.blue.shade400,
              Colors.blue.shade600,
              Colors.blue.shade800,
              Colors.blue.shade900,
            ],
          ),
        ),
      );
    }
  }

  Widget _foregroundWidget() {
    return Container(
      padding: EdgeInsets.only(top: _device_height * 0.02 + _statusbar_height),
      width: _device_width * 0.88,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _topBarWidget(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10.0),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
              // height: _device_height * 0.8,

              child: _moviesListWidget(),
            ),
          )
        ],
      ),
    );
  }

  Widget _topBarWidget() {
    return Container(
      height: _device_height * 0.07,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _searchFieldWidget(),
          _categorySelectionWidget(),
        ],
      ),
    );
  }

  Widget _searchFieldWidget() {
    return Container(
      height: _device_height * 0.05,
      width: _device_width * 0.5,
      child: TextField(
        controller: _searchTextFieldController,
        onSubmitted: (input) => _mainPageDataController.updateTextSearch(input),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
            focusedBorder: InputBorder.none,
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white38,
            ),
            hintText: "Search....",
            hintStyle: TextStyle(color: Colors.white12),
            filled: false,
            fillColor: Colors.white),
        cursorColor: Colors.white38,
      ),
    );
  }

  Widget _categorySelectionWidget() {
    return Container(
      child: DropdownButton(
        dropdownColor: Colors.black87,
        value: _mainPageData.searchCategory,
        icon: const Icon(
          Icons.menu,
          color: Colors.white70,
        ),
        items: const [
          DropdownMenuItem(
            child: Text(
              SearchCategory.popular,
              style: TextStyle(color: Colors.white),
            ),
            value: SearchCategory.popular,
          ),
          DropdownMenuItem(
            child: Text(
              SearchCategory.upcoming,
              style: TextStyle(color: Colors.white),
            ),
            value: SearchCategory.upcoming,
          ),
          DropdownMenuItem(
            child: Text(
              SearchCategory.none,
              style: TextStyle(color: Colors.white),
            ),
            value: SearchCategory.none,
          )
        ],
        onChanged: (_value) => _value.toString().isNotEmpty
            ? _mainPageDataController.updateSearchCategory(_value.toString())
            : null,
        underline: Container(
          height: 1.0,
          color: Colors.white24,
        ),
      ),
    );
  }

  Widget _moviesListWidget() {
    final List<Movie> _movies = _mainPageData.movies;
    // for (int i = 0; i < 20; i++) {
    //   _movies.add(Movie(
    //       name: 'Spider-Man: No Way Home',
    //       language: 'EN',
    //       description:
    //           "With Spider-Man's identity now revealed, our friendly neighborhood web-slinger is unmasked and no longer able to separate his normal life as Peter Parker from the high stakes of being a superhero. When Peter asks for help from Doctor Strange, the stakes become even more dangerous, forcing him to discover what it truly means to be Spider-Man.",
    //       posterPath: '/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg',
    //       backDropPath: '/1Rr5SrvHxMXHu5RjKpaMba8VTzi.jpg',
    //       releaseDate: 'March 4, 2022',
    //       isAdult: true,
    //       rating: 9.8));
    // }

    if (_movies.isNotEmpty) {
      return NotificationListener(
        onNotification: (_onScrollNotification) {
          if (_onScrollNotification is ScrollEndNotification) {
            final currentScrollPointWeAreAt =
                _onScrollNotification.metrics.extentBefore;
            final maxScrollAmount =
                _onScrollNotification.metrics.maxScrollExtent;

            if (currentScrollPointWeAreAt == maxScrollAmount) {
              //currentScrollPointWeAreAt == maxScrollAmount this implies that we have reached at the end of the list
              _mainPageDataController
                  .getMovies(); //While we reach the end of the list then update the _mainPageDataController
              //.getMovies() so that we get new list of movies
              return true;
            } else {
              return false;
            }
          } else {
            return false;
          }
        },
        child: ListView.builder(
          itemCount: _movies.length,
          itemBuilder: (BuildContext _context, int _count) {
            return GestureDetector(
              onTap: () {
                _selectedMoviePosterURL.state = _movies[_count].posterURL();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: _device_height * 0.01),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
                child: MovieTile(
                    height: _device_height * 0.2,
                    width: _device_width * 0.85,
                    movie: _movies[_count]),
              ),
            );
          },
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
        ),
      );
    }
  }
}
