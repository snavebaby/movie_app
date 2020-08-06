import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:switch_theme/core/models/movie_list_model.dart';

import 'package:switch_theme/core/models/movie_model.dart';
import 'package:http/http.dart' as http;

abstract class MoviesRepo {
  Future<MovieDetails> getMovieById(int id);
  Future<MovieList> getNextMoviesPage(String criteria, int page);
  Future<MovieList> getTrending(int page, String dw);
  Future<MovieList> getSimilarMovies(int id);
}

class MoviesApi implements MoviesRepo {
  final logger = Logger();
  static const imgUrl = "https://image.tmdb.org/t/p/w500/";
  String url(dynamic uri, {String language, int page}) =>
      "https://api.themoviedb.org/3/movie/$uri?api_key=$api_key&language=${language ?? "en-US"}&page=${page ?? 1}";
  static const api_key = "63795a93730c06f68c8c6d5f8cd9289e";
  @override
  Future<MovieDetails> getMovieById(int id) async {
    try {
      http.Response response = await http.get("${url(id)}");
      logger.i(response.statusCode);
      if (response.statusCode == 200) {
        return MovieDetails.fromJson(response.body);
      }
      throw Exception("Failed to Load $id movies");
    } catch (e) {
      logger.e(e.toString());
      throw Exception("Faled to load $id movies");
    }
  }

  Future<MovieList> getNextMoviesPage(String criteria, int page) async {
    logger.d(page);

    try {
      http.Response response = await http.get("${url(criteria, page: page)}");
      logger.i(response.body);
      if (response.statusCode == 200) {
        if (page >= jsonDecode(response.body)["total_pages"]) {
          throw NoNextPageException();
        }
        return MovieList.fromMap(jsonDecode(response.body));
      }
      throw Exception("Failed to Load $criteria movies");
    } catch (e) {
      logger.e(e);
      throw Exception("Failed to load $criteria movies");
    }
  }

  Future<MovieList> getTrending(int page, String dw) async {
    try {
      http.Response response = await http.get(
          "https://api.themoviedb.org/3/trending/movie/${dw}?api_key=${api_key}");

      if (response.statusCode == 200) {
        if (page >= jsonDecode(response.body)["total_pages"]) {
          throw NoNextPageException();
        }
        return MovieList.fromMap(jsonDecode(response.body));
      }
      throw Exception("Failed to Load trending movies");
    } catch (e) {
      logger.e(e);
      throw Exception("Failed to load trending movies");
    }
  }

  @override
  Future<MovieList> getSimilarMovies(int id) async {
    try {
      http.Response response = await http.get(
          "https://api.themoviedb.org/3/movie/${id}/similar?api_key=${api_key}");

      if (response.statusCode == 200) {
        return MovieList.fromMap(jsonDecode(response.body));
      }
      throw Exception("Failed to Load trending movies");
    } catch (e) {
      logger.e(e);
      throw Exception("Failed to load trending movies");
    }
  }

  Future<MovieDetails> getLatest() async {
    try {
      http.Response response = await http
          .get("https://api.themoviedb.org/3/movie/latest?api_key=${api_key}");

      if (response.statusCode == 200) {
        return MovieDetails.fromMap(jsonDecode(response.body));
      }
      throw Exception("Failed to Load trending movies");
    } catch (e) {
      logger.e(e);
      throw Exception("Failed to load trending movies");
    }
  }
}

class NoNextPageException implements Exception {}
