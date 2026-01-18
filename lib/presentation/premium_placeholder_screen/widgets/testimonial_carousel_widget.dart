import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget displaying user testimonials in a horizontal carousel
class TestimonialCarouselWidget extends StatefulWidget {
  const TestimonialCarouselWidget({super.key});

  @override
  State<TestimonialCarouselWidget> createState() =>
      _TestimonialCarouselWidgetState();
}

class _TestimonialCarouselWidgetState extends State<TestimonialCarouselWidget> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _testimonials = [
    {
      'name': 'Marco R.',
      'rating': 5,
      'comment':
          'Grazie a Guidingo ho superato l\'esame al primo tentativo! L\'app è fantastica e molto intuitiva.',
      'avatar':
          'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
      'semanticLabel':
          'Profile photo of a young man with short brown hair wearing a casual blue shirt',
    },
    {
      'name': 'Sofia M.',
      'rating': 5,
      'comment':
          'La versione Premium vale ogni centesimo. Poter studiare offline è stato fondamentale per me.',
      'avatar':
          'https://img.rocket.new/generatedImages/rocket_gen_img_19df3b9f3-1763299821151.png',
      'semanticLabel':
          'Profile photo of a young woman with long dark hair and a friendly smile',
    },
    {
      'name': 'Luca B.',
      'rating': 5,
      'comment':
          'Metodo di apprendimento gamificato perfetto! Mi sono divertito mentre studiavo per la patente.',
      'avatar':
          'https://img.rocket.new/generatedImages/rocket_gen_img_19b9f856b-1763296945059.png',
      'semanticLabel':
          'Profile photo of a man with glasses and short black hair wearing a white t-shirt',
    },
    {
      'name': 'Giulia T.',
      'rating': 5,
      'comment':
          'Le statistiche avanzate mi hanno aiutato a capire dove dovevo migliorare. Promossa!',
      'avatar':
          'https://img.rocket.new/generatedImages/rocket_gen_img_149f3bcac-1763298667408.png',
      'semanticLabel':
          'Profile photo of a young woman with blonde hair and blue eyes smiling at camera',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Text(
            'Cosa Dicono i Nostri Utenti',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        CarouselSlider.builder(
          itemCount: _testimonials.length,
          itemBuilder: (context, index, realIndex) {
            final testimonial = _testimonials[index];
            return _buildTestimonialCard(theme, testimonial);
          },
          options: CarouselOptions(
            height: 25.h,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeInOut,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        SizedBox(height: 2.h),
        _buildCarouselIndicator(theme),
      ],
    );
  }

  Widget _buildTestimonialCard(
    ThemeData theme,
    Map<String, dynamic> testimonial,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: CustomImageWidget(
                  imageUrl: testimonial['avatar'] as String,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  semanticLabel: testimonial['semanticLabel'] as String,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial['name'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: List.generate(
                        testimonial['rating'] as int,
                        (index) => Padding(
                          padding: EdgeInsets.only(right: 1.w),
                          child: CustomIconWidget(
                            iconName: 'star',
                            color: const Color(0xFFF39C12),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                testimonial['comment'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselIndicator(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _testimonials.length,
        (index) => Container(
          width: _currentIndex == index ? 8.w : 2.w,
          height: 1.h,
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
