import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function()? onPressed;
  final Widget? child;
  final String? text;
  const CustomButton({
    super.key,
    required this.onPressed,
    this.child,
    this.text,
  }) : assert(
         child != null || text != null,
         'Either text or child should be provided!',
       );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed == null
            ? null
            : () async {
                await onPressed?.call();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            child ??
            Text(
              text!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
      ),
    );
  }
}
