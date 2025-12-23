import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/common/widget/circular_icon_and_text/custom_icon_and_text.dart';
import 'package:whats_app/common/widget/section_heading/section_heading.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/feature/screens/calls_screen/widget/call_list.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class call_screen extends StatelessWidget {
  const call_screen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = MyHelperFunction.isDarkMode(context);
    return Scaffold(
      // floation_ac_btn
      floatingActionButton: SizedBox(
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
            Icons.add_call,
            size: Mysize.iconMd,
            color: isDark ? Mycolors.black : Mycolors.white,
          ),
        ),
      ),

      // AppBar
      appBar: AppBar(
        title: Text("Calls", style: Theme.of(context).textTheme.headlineMedium),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: MyPadding.screenPadding,
          child: Column(
            children: [
              // 1st_heading
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Custom_circualar_icon_and_text(
                    icon: Icons.call,
                    text: "Call",
                    onTap: () {},
                  ),

                  Custom_circualar_icon_and_text(
                    icon: Icons.calendar_month,
                    text: "Schedule",
                    onTap: () {},
                  ),

                  Custom_circualar_icon_and_text(
                    icon: Icons.dialpad_outlined,
                    text: "Keypad",
                    onTap: () {},
                  ),

                  Custom_circualar_icon_and_text(
                    icon: Iconsax.heart,
                    text: "Favoutite",
                    onTap: () {},
                  ),
                ],
              ),

              SizedBox(height: Mysize.spaceBtwSections),
              // calls_section
              MySectionHeading(title: "Recent", showActionBtn: false),
              SizedBox(height: Mysize.spaceBtwItems),
              Calls_list(),
            ],
          ),
        ),
      ),
    );
  }
}
