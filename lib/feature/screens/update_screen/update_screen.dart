import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/common/widget/custom_outline_button/outline_btn.dart';
import 'package:whats_app/common/widget/section_heading/section_heading.dart';
import 'package:whats_app/common/widget/status_widget/update_screen_status_widget.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/feature/screens/update_screen/widgets/fing_channel_section.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/const/text.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class update_screen extends StatelessWidget {
  const update_screen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = MyHelperFunction.isDarkMode(context);
    return Scaffold(
      // floatingActionButton
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 1st_button
          SizedBox(
            height: 40,
            width: 40,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: isDark ? Mycolors.light : Mycolors.dark,
                side: BorderSide.none,
              ),
              child: Center(
                child: Icon(
                  Iconsax.edit_2,
                  size: Mysize.iconMd,
                  color: isDark ? Mycolors.dark : Mycolors.light,
                ),
              ),
            ),
          ),

          SizedBox(height: Mysize.sm),

          // 2nd_button
          SizedBox(
            height: Mysize.floatingButtonHeight,
            width: Mysize.addfloatingButtonWidth,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: const Color.fromARGB(255, 2, 173, 65),
                side: BorderSide.none,
              ),
              child: Icon(
                Icons.camera_enhance_rounded,
                size: Mysize.iconMd,
                color: isDark ? Mycolors.dark : Mycolors.light,
              ),
            ),
          ),
        ],
      ),

      // AppBar
      appBar: AppBar(
        title: Text(
          MyText.Update,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: MyPadding.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // status_text
              Text(
                MyText.Update_status,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: Mysize.spaceBtwInputFields),

              // add_status_section
              status_widget(),
              SizedBox(height: Mysize.spaceBtwSections),

              // channels_section
              Text(
                MyText.Channels,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: Mysize.sm),
              Text(MyText.stay_update_text),
              SizedBox(height: Mysize.spaceBtwItems),

              // find_channel_section
              MySectionHeading(title: MyText.find_channel),
              SizedBox(height: Mysize.spaceBtwItems),
              find_channel_section(),

              // button's
              Custom_button(icon: Iconsax.activity, text: "Explore more"),
              SizedBox(height: Mysize.spaceBtwItems),
              Custom_button(icon: Iconsax.add, text: "Create Channel"),
            ],
          ),
        ),
      ),
    );
  }
}
