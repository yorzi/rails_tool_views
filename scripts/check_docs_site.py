#!/usr/bin/env python3
"""Check built local links and prevent internal records entering the site."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urlparse,unquote
import re
root=Path('docs/site/_site').resolve();bad=[];count=0
config=Path('docs/site/_config.yml').read_text()
match=re.search(r'^baseurl:\s*[\"\']?([^\"\'\n]*)',config,re.M)
base=match.group(1).strip().rstrip('/') if match else ''
class Links(HTMLParser):
 def __init__(self):super().__init__();self.links=[]
 def handle_starttag(self,t,a):
  attrs=dict(a)
  if t in ['a','link','script','img']:
   ref=attrs.get('href' if t in ['a','link'] else 'src')
   if ref:self.links.append(ref)
pages = list(root.rglob('*.html'))
if not pages or not (root / 'index.html').is_file():
 raise SystemExit('Missing documentation build; run docs/bin/build.sh first')
for p in pages:
 parser=Links();parser.feed(p.read_text())
 for href in parser.links:
  u=urlparse(href)
  if u.scheme or u.netloc or not u.path:continue
  path=unquote(u.path)
  if base and path.startswith(base+'/'):q=root/path[len(base)+1:]
  elif path.startswith('/') and not base:q=root/path.lstrip('/')
  elif path.startswith('/'):continue
  else:q=p.parent/path
  if q.is_dir():q=q/'index.html'
  count+=1
  if not q.exists():bad.append((str(p.relative_to(root)),href))
print({'local_links_checked':count,'broken':bad[:40],'broken_count':len(bad)})
assert not bad
for folder in ['specs','agent','human','evidence','operations','adr']:
 for output in [root,root/'next',*root.glob('v[0-9]*')]:
  assert not (output/folder).exists(),str(output/folder)
print('Internal records excluded: PASS')
