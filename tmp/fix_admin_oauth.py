from pathlib import Path
p=Path('D:/PhamNguyenTuanDat_2380614580/frontend')
f=p/'android/app/src/main/AndroidManifest.xml';s=f.read_text();s=s.replace('            android:taskAffinity=""\n','');f.write_text(s)
f=p/'lib/main.dart';s=f.read_text(encoding='utf8');a=s.index("                        trailing: u['role'] == 'admin'");b=s.index('\n                      ),',a)
s=s[:a]+'''                        onTap: () => manageUser(Map<String, dynamic>.from(u)),
                        trailing: IconButton(
                          tooltip: 'Quản lý tài khoản',
                          onPressed: () => manageUser(Map<String, dynamic>.from(u)),
                          icon: const Icon(Icons.manage_accounts_outlined),
                        ),'''+s[b:]
pos=s.index('  Future<void> execute(')
s=s[:pos]+'''  Future<void> manageUser(Map<String, dynamic> user) async {
    const labels = {'parent': 'Phụ huynh', 'child': 'Trẻ em', 'staff': 'Nhân viên', 'admin': 'Quản trị viên'};
    final selected = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: Text(user['name']),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(user['email']),
        Text('Vai trò: ${labels[user['role']] ?? user['role']}'),
        Text(user['verified'] == true ? 'Email đã xác minh' : 'Email chưa xác minh'),
        const SizedBox(height: 16),
        if (user['role'] == 'admin') const Text('Tài khoản quản trị được bảo vệ, không thể đổi quyền tại đây.')
        else ...['parent', 'child', 'staff'].map((role) => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(labels[role]!),
          trailing: user['role'] == role ? const Icon(Icons.check) : const Icon(Icons.chevron_right),
          onTap: user['role'] == role ? null : () => Navigator.pop(ctx, role),
        )),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng'))],
    ));
    if (selected == null || !mounted) return;
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Xác nhận đổi quyền'),
      content: Text('Đổi ${user['name']} thành ${labels[selected]}?'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xác nhận'))],
    ));
    if (confirmed != true || !mounted) return;
    await execute(() async {
      await api.call('PATCH', '/admin/users/${user['id']}/role', {'role': selected});
      if (mounted) notify(context, 'Đã cập nhật quyền thành ${labels[selected]}');
    });
  }

'''+s[pos:];f.write_text(s,encoding='utf8')
