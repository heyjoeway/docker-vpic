#!/usr/bin/env python3

from html.parser import HTMLParser
from urllib.request import urlopen
from urllib.parse import urljoin

PAGE_URL = "https://vpic.nhtsa.dot.gov/downloads/"


class ZipLinkFinder(HTMLParser):
    def __init__(self):
        super().__init__()
        self.zip_url = None

    def handle_starttag(self, tag, attrs):
        if self.zip_url is not None:
            return

        if tag != "a":
            return

        for name, value in attrs:
            if name == "href" and value.lower().endswith(".zip"):
                self.zip_url = urljoin(PAGE_URL, value)
                return


def main():
    with urlopen(PAGE_URL, timeout=30) as resp:
        html = resp.read().decode("utf-8", errors="replace")

    parser = ZipLinkFinder()
    parser.feed(html)

    if not parser.zip_url:
        raise RuntimeError("No .zip URL found on page")

    print(parser.zip_url)


if __name__ == "__main__":
    main()
