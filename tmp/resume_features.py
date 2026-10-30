from pathlib import Path
source=Path('tmp/features.py').read_text(encoding='utf8')
source=source[source.index("f=p/'frontend/pubspec.yaml'"):]
source=source.replace('.read_text()',".read_text(encoding='utf8')").replace('.write_text(s)',".write_text(s,encoding='utf8')")
p=Path('D:/PhamNguyenTuanDat_2380614580')
exec(source)
