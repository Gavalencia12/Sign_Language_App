import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';
import 'package:speakhands_mobile/theme/text_styles.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';

class CarouselModal extends StatelessWidget {
  const CarouselModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int currentPage = 0;
    final PageController controller = PageController();

    final primaryColor = AppColors.primary(context);
    final secondaryColor = AppColors.secondary(context);
    final backgroundColor = AppColors.background(context);
    final surfaceColor = AppColors.surface(context);
    final textColor = AppColors.text(context);
    final loc = AppLocalizations.of(context)!;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.close,
                  size: 24,
                  color: textColor, 
                ),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 280,
              child: PageView(
                controller: controller,
                onPageChanged: (index) => currentPage = index,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pan_tool_alt, size: 80, color: primaryColor),
                      const SizedBox(height: 16),
                      Text(
                        loc.modal_1,
                        style: AppTextStyles.titleLargeLight.copyWith(color: textColor), 
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        loc.modal_1_text,
                        style: AppTextStyles.bodyText.copyWith(color: textColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: surfaceColor, // Color de superficie
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.videocam, size: 80, color: secondaryColor), // Color secundario
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.modal_2,
                        style: AppTextStyles.bodyText.copyWith(color: textColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.volume_up, size: 80, color: secondaryColor), 
                      const SizedBox(height: 16),
                      Text(
                        loc.modal_3,
                        style: AppTextStyles.titleLargeLight.copyWith(color: textColor), 
                      ),
                      const SizedBox(height: 10),
                      Text(
                        loc.modla_3_text,
                        style: AppTextStyles.bodyText.copyWith(color: textColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: textColor),
                  onPressed: currentPage > 0
                      ? () {
                          controller.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentPage == index
                            ? primaryColor 
                            : secondaryColor.withOpacity(0.5), 
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: textColor),
                  onPressed: currentPage < 2
                      ? () {
                          controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
