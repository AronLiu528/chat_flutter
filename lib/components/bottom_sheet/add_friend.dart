import 'package:flutter/material.dart';
import '../search_friend_bottom_sheet.dart';

class AddFriendBottomSheet extends StatelessWidget {
  const AddFriendBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 50),
      child: Row(
        children: [
          // 搜尋好友按鈕
          _BottomSheetIconButton(
            icon: Icons.search,
            label: '搜尋好友',
            onTap: () {
              Navigator.pop(context);
              _showBottomSheet(context);
            },
          ),
          // 掃描 QRCode 按鈕
          _BottomSheetIconButton(
            icon: Icons.qr_code_scanner,
            label: '掃描 QRCode',
            onTap: () {
              Navigator.pop(context);
              _navigateToQRCodeScanner(context);
            },
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => SearchFriendBottomSheet(),
    );
  }

  void _navigateToQRCodeScanner(BuildContext context) {
    // 建議使用 qr_code_scanner 套件
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Container(),
      ),
    );
  }
}

class _BottomSheetIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomSheetIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                // color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
