import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/common/widget/button/MyElevatedButton.dart';
import 'package:whats_app/common/widget/style/screen_padding.dart';
import 'package:whats_app/feature/personalization/controller/UserController.dart';
import 'package:whats_app/feature/personalization/controller/update_user_details/update_user_details_controller.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/const/text.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';
import 'package:whats_app/utiles/validation/Validations.dart';

class UpdateUserAbout extends StatelessWidget {
  UpdateUserAbout({super.key});

  final controller = UserController.instance;

  @override
  Widget build(BuildContext context) {
    bool isDark = MyHelperFunction.isDarkMode(context);
    final updateController = Get.put(UpdateUserDetailsController());

    return Scaffold(
      appBar: MyAppbar(
        showBackArrow: true,
        title: Text("About", style: Theme.of(context).textTheme.headlineMedium),
      ),

      floatingActionButton: MyElevatedButton(
        onPressed: () => updateController.updateUserAbout(),
        text: "Save",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      body: Padding(
        padding: MyPadding.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: updateController.upDateUserAboutFormKey,
              child: TextFormField(
                controller: updateController.about,
                validator: (value) =>
                    MyValidator.validateEmptyText("About", value),
                decoration: InputDecoration(
                  labelText: "About",
                  prefixIcon: Icon(Iconsax.user),
                ),
              ),
            ),
            SizedBox(height: Mysize.defaultSpace),
            Text(
              MyText.editUserAbout,
              textAlign: TextAlign.start,
              style: TextStyle(color: isDark ? Mycolors.light : Mycolors.dark),
            ),
          ],
        ),
      ),
    );
  }
}
