import 'package:flutter/material.dart';

class TargetsStatus extends StatelessWidget {
  final Color color;
  final String status;
  const TargetsStatus({
    Key? key,
    required this.color,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(status,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w300,
            )),
      ],
    );
  }
}
