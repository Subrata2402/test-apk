import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutterapp/core/api_client.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/presentations/profile/widgets/feedback_category_selector.dart';
import 'package:flutterapp/presentations/profile/widgets/feedback_glass_text_field.dart';
import 'package:flutterapp/presentations/profile/widgets/feedback_rating_selector.dart';
import 'package:flutterapp/presentations/profile/widgets/feedback_submit_button.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/orb.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _category = 'bug'; // 'bug' | 'feature_request' | 'other'
  int _rating = 5;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final deviceInfo = {
        'os': Platform.operatingSystem,
        'osVersion': Platform.operatingSystemVersion,
        'locale': Platform.localeName,
        'platform': Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Web'),
      };

      final response = await ApiClient.instance.post('/feedback', {
        'category': _category,
        'rating': _rating,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'deviceInfo': deviceInfo,
      });

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Thank you for your feedback!'), backgroundColor: Colors.green));
          Navigator.of(context).pop();
        }
      } else {
        throw Exception('Failed to submit feedback');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg3,
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.bg1, AppColors.bg2, AppColors.bg3],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // Bokeh orbs
          Positioned(
            top: -context.scale(120),
            left: -context.scale(80),
            child: Orb(size: context.scale(300), color: AppColors.orb1.withValues(alpha: 0.30)),
          ),
          Positioned(
            bottom: -context.scale(60),
            right: -context.scale(60),
            child: Orb(size: context.scale(240), color: AppColors.orb4.withValues(alpha: 0.22)),
          ),

          // Content
          Column(
            children: [
              // Glass AppBar
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.07),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          context.scale(4),
                          context.scale(8),
                          context.scale(16),
                          context.scale(12),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: context.scale(22)),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Text(
                              'Submit Feedback',
                              style: GoogleFonts.inter(
                                fontSize: context.scale(18),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(24)),
                  child: SafeArea(
                    top: false,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Selector
                          _buildSectionHeader('CATEGORY'),
                          SizedBox(height: context.scale(10)),
                          FeedbackCategorySelector(
                            selectedCategory: _category,
                            onCategoryChanged: (val) => setState(() => _category = val),
                          ),
                          SizedBox(height: context.scale(24)),

                          // Rating Selector
                          _buildSectionHeader('RATING'),
                          SizedBox(height: context.scale(10)),
                          FeedbackRatingSelector(
                            rating: _rating,
                            onRatingChanged: (val) => setState(() => _rating = val),
                          ),
                          SizedBox(height: context.scale(24)),

                          // Title Input
                          _buildSectionHeader('TITLE'),
                          SizedBox(height: context.scale(10)),
                          FeedbackGlassTextField(
                            controller: _titleController,
                            hintText: 'Brief summary of your feedback',
                            validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                          ),
                          SizedBox(height: context.scale(24)),

                          // Description Input
                          _buildSectionHeader('DESCRIPTION'),
                          SizedBox(height: context.scale(10)),
                          FeedbackGlassTextField(
                            controller: _descriptionController,
                            hintText: 'Provide details about your experience, bug, or feature request...',
                            maxLines: 6,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Description is required' : null,
                          ),
                          SizedBox(height: context.scale(32)),

                          // Submit Button
                          FeedbackSubmitButton(isLoading: _isLoading, onPressed: _submitFeedback),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: 0.45),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
