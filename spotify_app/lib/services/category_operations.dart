import 'package:spotify_app/models/category.dart';

class CategoryOperations {
  static List<Category> getCategories() {
    return [
      Category(
        'Top Hits',
        'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=150&h=150&fit=crop',
      ),
      Category(
        'Hindi Songs',
        'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=150&h=150&fit=crop',
      ),
      Category(
        'Punjabi',
        'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=150&h=150&fit=crop',
      ),
      Category(
        'Old Songs',
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=150&h=150&fit=crop',
      ),
      Category(
        'Romantic',
        'https://images.unsplash.com/photo-1522441815192-d9f04eb0615c?w=150&h=150&fit=crop',
      ),
      Category(
        'Party Mix',
        'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=150&h=150&fit=crop',
      ),
    ];
  }
}