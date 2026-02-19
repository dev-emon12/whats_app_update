import 'package:flutter/material.dart';
import 'package:whats_app/common/widget/shimmerEffect/shimmerEffect.dart';

class ShimmerHorizontalList extends StatelessWidget {
  const ShimmerHorizontalList({
    super.key,
    this.count = 6,
    this.height = 160,
    this.itemWidth = 150,
    this.itemHeight = 160,
  });

  final int count;
  final double height;
  final double itemWidth;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ShimmerEffect(width: itemWidth, height: itemHeight);
        },
      ),
    );
  }
}
