import 'package:flutter/material.dart';
import 'package:whats_app/common/widget/shimmerEffect/shimmerEffect.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          // show image in full screen
          showDialog(
            context: context,
            builder: (_) => Dialog(
              insetPadding: EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InteractiveViewer(
                  child: SizedBox(
                    width: double.infinity,
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: ShimmerEffect(width: 300, height: 400),
                        );
                      },
                      errorBuilder: (_, __, ___) => Padding(
                        padding: EdgeInsets.all(20),
                        child: Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },

        // show image in main screen
        child: Image.network(
          url,
          width: 150,
          height: 160,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return ShimmerEffect(width: 150, height: 160);
          },
          errorBuilder: (_, __, ___) => SizedBox(
            width: 150,
            height: 160,
            child: Center(child: Icon(Icons.broken_image)),
          ),
        ),
      ),
    );
  }
}
