"""Generate bundled, paper-textured folk-art illustrations for the Flutter app."""
from pathlib import Path
import random
from PIL import Image, ImageDraw, ImageFilter

OUT = Path(__file__).resolve().parents[1] / "client" / "images" / "folk"
OUT.mkdir(parents=True, exist_ok=True)
INK = "#594333"
GREEN = "#355747"
SAGE = "#8B9F81"
PALE = "#E3E9DC"
GOLD = "#D4AC68"
RED = "#C86F4A"
PAPER = "#F7F1E5"


def canvas(size=(900, 620), seed=4):
    random.seed(seed)
    im = Image.new("RGB", size, PAPER)
    d = ImageDraw.Draw(im, "RGBA")
    for _ in range(size[0] * size[1] // 1100):
        x, y = random.randrange(size[0]), random.randrange(size[1])
        d.ellipse((x, y, x + 2, y + 1), fill=(89, 67, 51, random.randrange(5, 18)))
    return im


def line(d, points, fill=INK, width=5):
    d.line(points, fill=fill, width=width, joint="curve")


def mountain(d, x, y, w, h, fill):
    d.polygon([(x, y+h), (x+w*.25, y+h*.38), (x+w*.43, y+h*.62),
               (x+w*.67, y), (x+w, y+h)], fill=fill)
    line(d, [(x+w*.25, y+h*.38), (x+w*.31, y+h*.54), (x+w*.43, y+h*.62)], INK, 3)
    line(d, [(x+w*.67, y), (x+w*.72, y+h*.18), (x+w*.8, y+h*.2)], INK, 3)


def pagoda(d, x, y, scale=1, ink=INK):
    def poly(coords, fill, outline=ink, width=4):
        coords = [(int(x+a*scale), int(y+b*scale)) for a,b in coords]
        d.polygon(coords, fill=fill)
        line(d, coords+[coords[0]], outline, max(2, int(width*scale)))
    poly([(60,155),(145,100),(230,155),(215,170),(205,161),(200,178),(90,178),(85,161),(75,170)], "#D9A45C")
    poly([(78,178),(222,178),(210,195),(195,190),(190,205),(110,205),(105,190),(90,195)], "#F4DCA7")
    poly([(98,205),(202,205),(198,222),(188,218),(184,232),(116,232),(112,218),(102,222)], "#D9A45C")
    d.rectangle((int(x+112*scale),int(y+232*scale),int(x+188*scale),int(y+340*scale)), fill="#E8D6AE", outline=ink, width=max(2,int(4*scale)))
    d.rectangle((int(x+141*scale),int(y+258*scale),int(x+159*scale),int(y+340*scale)), fill="#815B3E", outline=ink, width=max(2,int(3*scale)))
    for wx in (122,174):
        d.rectangle((int(x+wx*scale),int(y+252*scale),int(x+(wx+10)*scale),int(y+274*scale)), fill="#A8B8A0", outline=ink, width=2)
    line(d, [(x+150*scale,y+98*scale),(x+150*scale,y+58*scale),(x+162*scale,y+48*scale)], ink, max(2,int(4*scale)))
    d.ellipse((x+156*scale,y+43*scale,x+168*scale,y+55*scale), fill=GOLD, outline=ink, width=2)


def bamboo(d, x, y, scale=1, flip=1):
    for i in range(3):
        bx=x+i*17*scale*flip
        line(d, [(bx,y),(bx+5*scale,y-130*scale)], GREEN, max(2,int(5*scale)))
        for t in (0.25,0.5,0.75):
            cy=y-t*130*scale
            line(d, [(bx-4*scale,cy),(bx+6*scale,cy+2)], INK, max(1,int(2*scale)))
        for dy, side in ((-105,-1),(-75,1),(-42,-1)):
            cx=bx+3*scale; cy=y+dy*scale
            ax, bx = cx+side*24*scale, cx+side*5*scale
            d.ellipse((min(ax,bx),cy-10*scale,max(ax,bx),cy+1*scale), fill=SAGE, outline=GREEN, width=2)


def lotus(d, x, y, scale=1):
    for dx, color in ((-14, "#D9A49A"),(0,"#F1C5B6"),(14,"#D9A49A")):
        d.ellipse((x+(dx-9)*scale,y-26*scale,x+(dx+9)*scale,y+8*scale), fill=color, outline=INK, width=2)
    d.ellipse((x-11*scale,y-1*scale,x+11*scale,y+12*scale), fill=GOLD, outline=INK, width=2)
    line(d, [(x-35*scale,y+17*scale),(x,y+12*scale),(x+34*scale,y+17*scale)], GREEN, 3)


def hero():
    im=canvas((1100,700), 12); d=ImageDraw.Draw(im,"RGBA")
    d.ellipse((790,60,910,180),fill=(212,172,104,85))
    mountain(d,0,220,520,300,"#DCE4D4"); mountain(d,400,190,650,340,"#CAD8C7")
    # distant temple and winding stone path
    pagoda(d,440,255,.85)
    d.polygon([(0,610),(260,535),(450,560),(640,515),(850,565),(1100,520),(1100,700),(0,700)], fill="#A6B28C")
    d.polygon([(515,700),(595,700),(575,625),(650,565),(570,580),(510,625)], fill="#D8C9A9")
    # lotus pond
    d.ellipse((180,560,540,680),fill="#9DAF9B",outline=GREEN,width=4)
    for xx,yy in ((240,605),(315,640),(420,590),(480,635)): lotus(d,xx,yy,.8)
    bamboo(d,70,620,1.2); bamboo(d,1015,620,1.2,-1)
    # clouds / birds
    for cx,cy in ((170,170),(845,230)):
        line(d,[(cx,cy),(cx+36,cy-7),(cx+70,cy),(cx+102,cy-7)],"#A68D70",3)
    for bx,by in ((760,200),(800,170),(280,255)):
        line(d,[(bx,by+8),(bx+9,by),(bx+18,by+8)],INK,3)
    im.save(OUT/"pagoda-hero.png")


def feature(name, kind, seed):
    im=canvas((720,420),seed); d=ImageDraw.Draw(im,"RGBA")
    # soft medallion
    d.ellipse((150,12,570,405),fill=(227,233,220,180))
    if kind=="temple":
        mountain(d,180,110,370,190,"#CBD9C4"); pagoda(d,250,60,1.12)
        bamboo(d,160,365,.8); bamboo(d,545,365,.8,-1)
    elif kind=="map":
        d.polygon([(175,95),(335,62),(535,100),(520,345),(352,310),(190,350)], fill="#F4DFAF", outline=INK)
        line(d,[(175,95),(190,350),(352,310),(335,62),(520,100),(535,345)],INK,4)
        for pts in [[(230,285),(300,230),(375,250),(445,175)],[(235,160),(310,185),(390,130)]]: line(d,pts,"#9A8060",5)
        d.ellipse((365,95,430,160),fill=RED,outline=INK,width=4); d.polygon([(375,145),(420,145),(397,210)],fill=RED,outline=INK)
        d.ellipse((385,112,410,137),fill=PAPER,outline=INK,width=2)
    elif kind=="calendar":
        d.rounded_rectangle((235,55,495,355),25,fill="#FFF9EF",outline=INK,width=5)
        d.rounded_rectangle((235,55,495,130),25,fill=GREEN,outline=INK,width=5)
        for xx in (295,435): line(d,[(xx,40),(xx,80)],INK,9)
        for yy in (175,235,295):
            for xx in (290,355,420): d.ellipse((xx,yy,xx+22,yy+22),fill=GOLD if (xx+yy)%2 else RED,outline=INK,width=2)
        lotus(d,365,285,1.35)
        for x in (195,540):
            line(d,[(x,345),(x,190)],GREEN,4)
            d.ellipse((x-25,225,x+25,285),fill="#E6B56D",outline=INK,width=3)
            line(d,[(x,285),(x,340)],INK,2)
    elif kind=="event":
        pagoda(d,250,105,.85)
        for x,y in ((210,90),(495,90),(555,150)):
            d.ellipse((x-18,y-18,x+18,y+18),fill="#E5B66C",outline=INK,width=3)
            line(d,[(x,y+18),(x,y+55)],INK,2)
        for x,y,c in ((265,330,"#C86F4A"),(365,340,"#8B9F81"),(465,330,"#D4AC68")):
            d.ellipse((x-20,y-70,x+20,y-30),fill="#D5AC86",outline=INK,width=2)
            d.polygon([(x-32,y-31),(x+32,y-31),(x+48,y+32),(x-46,y+32)],fill=c,outline=INK)
    elif kind=="saved":
        d.polygon([(210,100),(355,125),(355,345),(210,320)],fill="#E7D2AA",outline=INK)
        d.polygon([(355,125),(515,93),(515,315),(355,345)],fill="#FFF9EF",outline=INK)
        line(d,[(355,126),(355,345)],INK,5)
        for yy in (175,220,265):
            line(d,[(235,yy),(325,yy+14)],"#B89C75",3); line(d,[(385,yy+5),(480,yy-8)],"#B89C75",3)
        lotus(d,425,220,1.45)
        d.polygon([(470,95),(500,95),(500,205),(485,188),(470,205)],fill=RED,outline=INK)
    im.save(OUT/f"{name}.png")


def main():
    hero()
    for args in [("temple-search","temple",21),("hand-drawn-map","map",22),
                 ("festival-calendar","calendar",23),("temple-event","event",24),
                 ("saved-journal","saved",25)]: feature(*args)
    im=canvas((256,256),8); d=ImageDraw.Draw(im,"RGBA")
    lotus(d,128,175,2.1); pagoda(d,70,10,.42)
    im.save(OUT/"lotus-logo.png")


if __name__=="__main__": main()
