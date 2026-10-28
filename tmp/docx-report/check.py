from pdf2image import convert_from_path
from PIL import Image,ImageOps,ImageDraw
from pathlib import Path
p=Path('tmp/docx-report'); pdf=convert_from_path(str(p/'preview.pdf'),dpi=85,poppler_path=r'C:/Users/DatPNT/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/poppler/Library/bin');print('Pages',len(pdf))
for i,page in enumerate(pdf):
 page.save(p/f'page-{i+1}.png')
for start in range(0,len(pdf),9):
 sheet=Image.new('RGB',(900,1320),'#bbb');d=ImageDraw.Draw(sheet)
 for n in range(start,min(start+9,len(pdf))):
  im=Image.open(p/f'page-{n+1}.png');im.thumbnail((290,410))
  x=((n-start)%3)*300;y=((n-start)//3)*440
  sheet.paste(im,(x,y+20));d.text((x+5,y+3),str(n+1),fill='black')
 sheet.save(p/f'contact-{start//9}.png')


