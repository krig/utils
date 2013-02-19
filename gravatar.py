# gravatar.py  Copyright (C) 2008  Kristoffer Gronlund
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
import os, time, urllib
try:
    from hashlib import md5
except ImportError:
    import md5 as md5lib
    md5 = md5lib.new

_BASEPATH = "~/.cache/pygravatar/%s_%d"
_OLDAGE = 24 # age in hours

def _makemd5(email):
    return md5(email.lower()).hexdigest()

def _makename(emailmd5, size):
    return os.path.expanduser(_BASEPATH % (emailmd5, size))

def _older(filename, hours):
    mtime = os.path.getmtime(filename)
    return (time.time() - mtime) > (hours * 3600)

def _dirty(filename):
    ex = os.path.exists(filename)
    return not ex or _older(filename, _OLDAGE)

def _makeurl(emailmd5, size):
    """Constructs the Gravatar URL.
    """
    gravatar_url =  "http://www.gravatar.com/avatar/"
    gravatar_url += emailmd5
    gravatar_url += '?' + urllib.urlencode({'d':'monsterid', 's': str(size)})
    return gravatar_url

def get(email = "someone@example.com",
        size = 80):
    """Looks in local cache if file exists
    and is newer than TIMEOUT. If not, fetches
    a new image and puts it in the cache.
    Returns local path to image."""
    emailmd5 = _makemd5(email)
    filename = _makename(emailmd5, size)
    if _dirty(filename):
        try:
            os.makedirs(os.path.split(filename)[0])
        except os.error:
            pass
        url = _makeurl(emailmd5, size)
        urllib.urlretrieve(url, filename)
    return filename

if __name__ == "__main__":
    # requires PIL installed
    import Image
    im = Image.open(get(email="someone@example.com"))
    print im.format, im.size, im.mode

