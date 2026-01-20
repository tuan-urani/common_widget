import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:link_home/src/extensions/int_extensions.dart';
import 'package:link_home/src/utils/app_colors.dart';

/// Hiển thị Cupertino Date Picker trong bottom sheet iOS-style bằng GetX.
///
/// [initialDateTime] - ngày giờ ban đầu hiển thị.
/// [onDateTimeChanged] - callback trả về giá trị người dùng chọn.
/// [minimumDate], [maximumDate] - tùy chọn giới hạn ngày.
Future<void> showCupertinoDatePickerBottomSheet({
  required DateTime initialDateTime,
  required ValueChanged<DateTime> onDateTimeChanged,
  DateTime? minimumDate,
  DateTime? maximumDate,
}) async {
  DateTime tempPickedDate = initialDateTime;

  await Get.bottomSheet(
    Container(
      height: 300,
      color: AppColors.white,
      child: Column(
        children: [
          // Thanh nút Cancel / Done
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: 16.paddingHorizontal,
                  child: const Text('Cancel'),
                  onPressed: () => Get.back(),
                ),
                CupertinoButton(
                  padding: 16.paddingHorizontal,
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Get.back();
                    onDateTimeChanged(tempPickedDate);
                  },
                ),
              ],
            ),
          ),
          // Picker chính
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: initialDateTime,
              minimumDate: minimumDate,
              maximumDate: maximumDate,
              onDateTimeChanged: (DateTime newDate) {
                tempPickedDate = newDate;
              },
            ),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
  );
}
