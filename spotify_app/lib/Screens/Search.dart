import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotify_app/models/category.dart';
import 'package:spotify_app/models/music.dart';
import 'package:spotify_app/services/category_operations.dart';
import 'package:spotify_app/services/music_operations.dart';

class Search extends StatefulWidget {
  final Function _miniPlayer;

  const Search(this._miniPlayer, {super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController _searchController = TextEditingController();
  List<Music> _allMusic = [];
  List<Category> _allCategories = [];
  List<Music> _filteredMusic = [];
  List<Category> _filteredCategories = [];
  bool _isSearching = false;
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    _allMusic = MusicOperations.getMusic();
    _allCategories = CategoryOperations.getCategories();
    _filteredMusic = _allMusic;
    _filteredCategories = _allCategories;
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () {
      String query = _searchController.text.toLowerCase();
      setState(() {
        _searchQuery = query;
        _isSearching = query.isNotEmpty;

        if (query.isEmpty) {
          _filteredMusic = _allMusic;
          _filteredCategories = _allCategories;
        } else {
          _filteredMusic = _allMusic.where((music) {
            return music.name.toLowerCase().contains(query) ||
                music.desc.toLowerCase().contains(query);
          }).toList();

          _filteredCategories = _allCategories.where((category) {
            return category.name.toLowerCase().contains(query);
          }).toList();
        }
      });
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'What do you want to listen to?',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade800,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blueGrey.shade400,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child: Image.network(
                category.imageURL,
                fit: BoxFit.cover,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade600,
                    child: Icon(Icons.music_note, color: Colors.white),
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                category.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMusicCard(Music music) {
    return Card(
      color: Colors.grey.shade900,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            music.image,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 50,
                color: Colors.grey.shade600,
                child: Icon(Icons.music_note, color: Colors.white),
              );
            },
          ),
        ),
        title: Text(
          music.name,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          music.desc,
          style: TextStyle(color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(Icons.play_arrow, color: Colors.white),
        onTap: () {
          widget._miniPlayer(music);
        },
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    if (_filteredCategories.isEmpty) {
      return Center(
        child: Text(
          'No categories found',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        childAspectRatio: 3 / 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: _filteredCategories
            .map((category) => _buildCategoryCard(category))
            .toList(),
        crossAxisCount: 2,
      ),
    );
  }

  Widget _buildMusicList() {
    if (_filteredMusic.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No songs found',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _filteredMusic.length,
      itemBuilder: (context, index) {
        return _buildMusicCard(_filteredMusic[index]);
      },
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_filteredMusic.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Songs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildMusicList(),
          SizedBox(height: 16),
        ],
        if (_filteredCategories.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Categories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildCategoriesGrid(),
        ],
        if (_filteredMusic.isEmpty && _filteredCategories.isEmpty) ...[
          Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.search_off, color: Colors.grey, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'No results found for "$_searchQuery"',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBrowseAll() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Browse all',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 8),
        _buildCategoriesGrid(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildSearchBar(),
              SizedBox(height: 8),
              _isSearching ? _buildSearchResults() : _buildBrowseAll(),
            ],
          ),
        ),
      ),
    );
  }
}
