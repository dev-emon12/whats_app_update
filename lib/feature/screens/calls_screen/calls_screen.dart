import 'package:flutter/material.dart';
import 'package:whats_app/feature/screens/calls_screen/widget/callBottomSheet.dart';
import 'package:whats_app/feature/screens/calls_screen/widget/call_list.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyHelperFunction.isDarkMode(context);

    return Scaffold(
      floatingActionButton: SizedBox(
        height: Mysize.floatingButtonHeight,
        width: Mysize.anotherfloatingButtonWidth,
        child: ElevatedButton(
          onPressed: () => CallBottomSheetHelper.open(),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: const Color.fromARGB(255, 2, 173, 65),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 10,
            shadowColor: Colors.black26,
          ),
          child: Icon(
            Icons.add_call,
            size: Mysize.iconMd,
            color: isDark ? Mycolors.black : Mycolors.white,
          ),
        ),
      ),
      appBar: AppBar(
        title: Text("Calls", style: Theme.of(context).textTheme.headlineMedium),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [Expanded(child: Callslist())],
      ),
    );
  }
}
