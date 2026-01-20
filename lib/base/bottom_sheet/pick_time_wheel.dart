import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:link_home/src/extensions/color_extension.dart';
import 'package:link_home/src/utils/app_colors.dart';
import 'package:link_home/src/utils/app_dimensions.dart';
import 'package:link_home/src/utils/app_styles.dart';
import 'package:wheel_picker/wheel_picker.dart';

const double wheelItemHeight = 30.0;

Future<void> showYearWheelPickerBottomSheet({
  required int initialYear,
  required Function(int) onYearChanged,
  required int minimumYear,
  required int maximumYear,
}) async {
  int tempYearPickedDate = initialYear;

  final years = [for (int y = minimumYear; y <= maximumYear; y++) y];

  await Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Thanh Cancel / Done
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () => Get.back(),
                    ),
                    CupertinoButton(
                      child: const Text(
                        'Done',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        Get.back();
                        onYearChanged(tempYearPickedDate);
                      },
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildHighLightContainer(),
                    _buildJapaneseWheel(
                      items: years,
                      initialValue: tempYearPickedDate,
                      unit: '年',
                      onChanged: (v) {
                        setState(() {
                          tempYearPickedDate = v;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
    isScrollControlled: true,
  );
}

Future<void> showFullDateTimeWheelPickerBottomSheet({
  required int initialYear,
  required int initialMonth,
  required int initialDay,
  required int initialHour,
  required int initialMinute,
  required int minimumYear,
  required int maximumYear,
  required void Function(int year, int month, int day, int hour, int minute)
  onDone,
}) async {
  int year = initialYear;
  int month = initialMonth;
  int day = initialDay;
  int minute = initialMinute;

  // Convert 24h to 12h format with AM/PM
  bool isPM = initialHour >= 12;
  // 0h -> 12h (follow by AM)
  // > 12h -> minus -12 (PM)
  int hour12 =
      initialHour == 0
          ? 12
          : (initialHour > 12 ? initialHour - 12 : initialHour);

  List<int> years = [for (int y = minimumYear; y <= maximumYear; y++) y];
  List<int> months = [for (int m = 1; m <= 12; m++) m];
  List<int> hours12 = [for (int h = 1; h <= 12; h++) h];
  List<int> minutes = [for (int m = 0; m < 60; m++) m];

  // when change years, months => re-calculate list date
  int daysInMonth(int y, int m) {
    return DateTime(y, m + 1, 0).day;
  }

  // when change years, months => re-calculate list date
  List<int> days = [for (int d = 1; d <= daysInMonth(year, month); d++) d];

  await Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: 400,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              /// Header
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () => Get.back(),
                    ),
                    CupertinoButton(
                      child: const Text(
                        'Done',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        Get.back();
                        // Convert 12h format back to 24h
                        int hour24 =
                            hour12 == 12
                                ? (isPM ? 12 : 0)
                                : (isPM ? hour12 + 12 : hour12);
                        onDone(year, month, day, hour24, minute);
                      },
                    ),
                  ],
                ),
              ),

              /// Wheels
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildHighLightContainer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildJapaneseWheel(
                                items: years,
                                initialValue: year,
                                unit: '年',
                                onChanged: (v) {
                                  setState(() {
                                    year = v;
                                    days = [
                                      for (
                                        int d = 1;
                                        d <= daysInMonth(year, month);
                                        d++
                                      )
                                        d,
                                    ];
                                    // if (day > days.length) day = days.last;
                                  });
                                },
                              ),
                              _buildJapaneseWheel(
                                items: months,
                                initialValue: month,
                                unit: '月',
                                onChanged: (v) {
                                  setState(() {
                                    month = v;
                                    days = [
                                      for (
                                        int d = 1;
                                        d <= daysInMonth(year, month);
                                        d++
                                      )
                                        d,
                                    ];
                                    // if (day > days.length) day = days.last;
                                  });
                                },
                              ),
                              _buildJapaneseWheel(
                                items: days,
                                initialValue: day,
                                unit: '日',
                                onChanged: (v) => setState(() => day = v),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildHighLightContainer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildJapaneseWheel(
                                items: hours12,
                                initialValue: hour12,
                                unit: '時',
                                onChanged: (v) => setState(() => hour12 = v),
                              ),
                              _buildJapaneseWheel(
                                items: minutes,
                                initialValue: minute,
                                unit: '分',
                                onChanged: (v) => setState(() => minute = v),
                              ),
                              _buildAmPmWheel(
                                initialValue: isPM ? 'PM' : 'AM',
                                onChanged:
                                    (v) => setState(() => isPM = v == 'PM'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
    isScrollControlled: true,
  );
}

Future<void> showYearMonthWheelPickerBottomSheet({
  required int initialYear,
  required int initialMonth,
  required int minimumYear,
  required int maximumYear,
  required void Function(int year, int month) onDone,
}) async {
  int year = initialYear;
  int month = initialMonth;

  final years = [for (int y = minimumYear; y <= maximumYear; y++) y];
  final months = [for (int m = 1; m <= 12; m++) m];

  await Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) {
        return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          /// Header
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Get.back(),
                ),
                CupertinoButton(
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Get.back();
                    onDone(year, month);
                  },
                ),
              ],
            ),
          ),

          /// Wheels
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildHighLightContainer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildJapaneseWheel(
                      items: years,
                      initialValue: year,
                      unit: '年',
                      onChanged: (v) => setState(() => year = v),
                    ),
                    _buildJapaneseWheel(
                      items: months,
                      initialValue: month,
                      unit: '月',
                      onChanged: (v) => setState(() => month = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
      },
    ),
    isScrollControlled: true,
  );
}

Widget _buildJapaneseWheel({
  required List<int> items,
  required int initialValue,
  required String unit, // 年 月 日 時 分
  required ValueChanged<int> onChanged,
  double width = 80,
}) {
  int selectedValue = initialValue;
  return SizedBox(
    width: width,
    child: WheelPicker(
      looping: false,
      itemCount: items.length,
      initialIndex: items.indexOf(initialValue),
      onIndexChanged: (index, _) {
        selectedValue = items[index];
        onChanged(items[index]);
      },
      builder: (context, index) {
        final isSelected = items[index] == selectedValue;
        return Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  // auto add 0 for number 1 -> 9 for improving UX
                  text: items[index].toString().padLeft(2, '0'),
                  style: AppStyles.h5(
                    color:
                        isSelected
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                  ),
                ),
                TextSpan(
                  text: unit,
                  style: AppStyles.bodySmall(
                    color:
                        isSelected
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      style: const WheelPickerStyle(itemExtent: wheelItemHeight),
    ),
  );
}

Widget _buildHighLightContainer() {
  return Container(
    height: wheelItemHeight,
    margin: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: AppColors.black.withOpacityX(0.12),
      borderRadius: AppDimensions.borderRadius,
    ),
  );
}

Widget _buildAmPmWheel({
  required String initialValue,
  required ValueChanged<String> onChanged,
  double width = 80,
}) {
  final List<String> items = ['AM', 'PM'];
  String selectedValue = initialValue;

  return SizedBox(
    width: width,
    child: WheelPicker(
      looping: false,
      itemCount: items.length,
      initialIndex: items.indexOf(initialValue),
      onIndexChanged: (index, _) {
        selectedValue = items[index];
        onChanged(items[index]);
      },
      builder: (context, index) {
        final isSelected = items[index] == selectedValue;
        return Center(
          child: Text(
            items[index],
            style: AppStyles.h5(
              color:
                  isSelected ? AppColors.textPrimary : AppColors.textDisabled,
            ),
          ),
        );
      },
      style: const WheelPickerStyle(itemExtent: wheelItemHeight),
    ),
  );
}
