import 'dart:convert';

import 'package:assignment9/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List newsList = [];

  bool isLoading = true;

  final searchController = TextEditingController();

  final String apiKey =
      "b38051d5944d4cc99ecf47a4be6ba4a7";

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      final result = await http.get(
        Uri.parse(
          "https://newsapi.org/v2/everything?q=bitcoin&apiKey=$apiKey",
        ),
      );

      final response = jsonDecode(result.body);

      if (response['status'] == 'ok') {
        setState(() {
          newsList = response['articles'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          newsList = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        newsList = [];
        isLoading = false;
      });
    }
  }

  Future<void> searchNews() async {
    final query = searchController.text.trim();

    if (query.isEmpty) {
      fetchNews();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await http.get(
        Uri.parse(
          "https://newsapi.org/v2/everything?q=${Uri.encodeComponent(query)}&apiKey=$apiKey",
        ),
      );

      final response = jsonDecode(result.body);

      if (response['status'] == 'ok') {
        setState(() {
          newsList = response['articles'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          newsList = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        newsList = [];
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'News',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon:  Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                searchNews();
              },
              decoration: InputDecoration(
                hintText: 'Search news...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    searchNews();
                  },
                  icon:  Icon(Icons.arrow_circle_right_outlined),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ?  Center(
              child: CircularProgressIndicator(),
            )
                : newsList.isEmpty
                ?  Center(
              child: Text(
                'No news found',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )
                : ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final news = newsList[index];

                final imageUrl = news['urlToImage'];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        if (imageUrl != null &&
                            imageUrl.toString().isNotEmpty)
                          ClipRRect(
                            borderRadius:
                            BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stack) {
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey.shade200,
                                  child:  Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                         SizedBox(height: 10),

                        Text(
                          news['title'] ?? '',
                          style:  TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                         SizedBox(height: 7),

                        Text(
                          news['description'] ?? '',
                          style:  TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),

                         SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}