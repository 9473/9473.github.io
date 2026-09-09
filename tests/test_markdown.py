import os
import tempfile
import unittest
from pathlib import Path
import build


class MarkdownPublishingTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.cwd = Path.cwd()
        os.chdir(self.temp.name)

    def tearDown(self):
        os.chdir(self.cwd)
        self.temp.cleanup()

    def write(self, name, text=''):
        path = Path(name)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
        return path

    def test_only_blog_and_notes_entries_are_published(self):
        for name in ('Blog/post/index.md', 'Docs/note/index.md', 'CV/index.md',
                     'Blog/draft.md', 'Blog/_draft/index.md'):
            self.write('content/' + name)
        self.assertEqual(build.find_markdown_files(), [Path('content/Blog/post/index.md'), Path('content/Docs/note/index.md')])
        self.write('content/Blog/post/index.typ')
        with self.assertRaises(ValueError):
            build.find_markdown_files()

    def test_index_links_are_escaped_sorted_and_not_duplicated(self):
        self.write('_site/Blog/index.html', '<section><h1>Blog</h1><p>Existing links</p></section>')
        sources = []
        for slug, date in [('old', '2025-01-01'), ('new', '2026-09-07')]:
            sources.append(self.write(f'content/Blog/{slug}/index.md'))
            self.write(f'_site/Blog/{slug}/index.html', f'<title>A &amp; B</title><meta name="date" content="{date}">')
        build.update_markdown_indexes(sources)
        first = Path('_site/Blog/index.html').read_text()
        build.update_markdown_indexes(sources)
        self.assertEqual(first, Path('_site/Blog/index.html').read_text())
        self.assertLess(first.index('/Blog/new/'), first.index('/Blog/old/'))
        self.assertIn('A &amp; B', first)
        self.assertIn('Existing links', first)
        build.update_markdown_indexes([])
        self.assertNotIn('/Blog/new/', Path('_site/Blog/index.html').read_text())

    def test_nested_image_change_rebuilds_markdown(self):
        source = self.write('content/Blog/post/index.md')
        target = self.write('_site/Blog/post/index.html')
        picture = self.write('content/Blog/post/imgs/plot.png')
        os.utime(source, (100, 100))
        os.utime(target, (200, 200))
        os.utime(picture, (100, 100))
        self.assertFalse(build.needs_rebuild(source, target))
        os.utime(picture, (300, 300))
        self.assertTrue(build.needs_rebuild(source, target))

    def test_blog_routes_chinese_to_sidebar(self):
        index = self.write('_site/Blog/index.html', '<div id="blog-posts"></div><aside><p>Existing journal</p><div id="blog-journals"></div></aside>')
        sources = []
        for slug, lang in [('technical', 'en'), ('diary', 'zh-CN')]:
            sources.append(self.write(f'content/Blog/{slug}/index.md'))
            self.write(f'_site/Blog/{slug}/index.html', f'<html lang="{lang}"><title>{slug}</title></html>')
        build.update_markdown_indexes(sources)
        first = index.read_text()
        main, sidebar = first.split('<aside>')
        self.assertIn('/Blog/technical/', main)
        self.assertNotIn('/Blog/diary/', main)
        self.assertIn('/Blog/diary/', sidebar)
        self.assertIn('Existing journal', sidebar)
        build.update_markdown_indexes(sources)
        self.assertEqual(first, index.read_text())
