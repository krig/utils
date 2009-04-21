#
# multidict
#
# Copyright (c) Kristoffer Gronlund, 2009
#
# a map over a pile of objects with multiple indices
# an index is defined by an index function
# each index gets a by_<id> member in the set, which
# is simply a dict using a particular key function to map the object

class _index(dict):
    def __init__(self, mdict):
        dict.__init__(self)
        self._mdict = mdict

    def __setitem__(self, name, value):
        raise AttributeError("setting values is not allowed on multidict indices, use add() on the multidict")

    def __delitem__(self, item):
        itm = dict.__getitem__(self, item)
        self._mdict.remove(itm)

    def priv_set(self, name, value):
        dict.__setitem__(self, name, value)

    def priv_del(self, item):
        dict.__delitem__(self, item)

class multidict(object):
    def __init__(self):
        self._indices = {}
        self._primary = None

    def __add_index(self, name, key_fun):
        if name in self._indices:
            raise IndexError('index %s already defined' % (name))
        idx = _index(self)

        if self._primary is not None:
            for itm in self._primary.values():
                idx.priv_set(key_fun(itm), itm)
        else:
            print "Setting primary index to %s", idx
            self._primary = idx

        setattr(self, 'by_'+name, idx)
        self._indices[name] = key_fun

    def __setitem__(self, name, value):
        if not callable(value):
            raise ValueError('Index function is not callable')
        self.__add_index(name, value)

    def add(self, item):
        if self._primary is None:
            raise IndexError("A primary index must be defined before adding items")
        for name, fn in self._indices.iteritems():
            idx = getattr(self, 'by_'+name)
            idx.priv_set(fn(item), item)

    def remove(self, item):
        for name, fn in self._indices.iteritems():
            idx = getattr(self, 'by_'+name)
            idx.priv_del(fn(item))

    def set_primary(self, name):
        if self._primary == getattr(self, 'by_'+name):
            return
        self._primary = getattr(self, 'by_'+name)
        # rebuild all other indices to drop all items
        # not referred from the new primary
        vals = self._primary.values()
        for nam, fn in self._indices.iteritems():
            if nam != name:
                idx = getattr(self, 'by_'+nam)
                idx.clear()
                for itm in vals:
                    idx.priv_set(fn(itm), itm)

    def __iter__(self):
        if self._primary is None:
            raise IndexError('No index defined on multidict')
        return self._primary.itervalues()

    def __len__(self):
        if self._primary is None:
            raise IndexError('No index defined on multidict')
        return len(self._primary)

    def __delattr__(self, name):
        if name.startswith('by_'):
            if self._primary == getattr(self, name):
                raise IndexError('Removing the primary index is illegal')
            del self._indices[name[3:]]
            object.__delattr__(self, name)
        else:
            return object.__delattr__(self, name)

    def __repr__(self):
        if self._primary is None:
            return "multidict()"
        else:
            return "multidict(%s)" % (self._primary)

def testing():
    import random

    d2 = multidict()

    class obj(object):
        def __init__(self, name, size):
            self.name = name
            self.size = size
            self.rnd = random.randint(0, 100)
        def __repr__(self):
            return "<%s, %s>" % (self.name, self.size)

    d2['name'] = lambda x: x.name
    d2['size'] = lambda x: x.size

    d2.add(obj('bill', 3))
    d2.add(obj('jane', 100))
    d2.add(obj('alice', 190))
    d2.add(obj('bob', 3))
    d2.add(obj('charlie', 100))
    d2.add(obj('foo', 100))

    for n, o in d2.by_name.iteritems():
        print "%s is %s" % (n, o)

    for s, o in d2.by_size.iteritems():
        print "%s is %s" % (s, o)

    for o in d2:
        print o

    del d2.by_name['bill']

    print d2

    for o in d2:
        print o

    del d2.by_size

    print d2
    try:
        for s, o in d2.by_size.iteritems():
            print "%s is %s" % (s, o)
    except AttributeError, e:
        print e

    d2['rand'] = lambda x: x.rnd

    for r, o in d2.by_rand.iteritems():
        print "%s is %s" % (r, o)

    try:
        del d2.by_name
    except IndexError, e:
        print e

    d2['size'] = lambda x: x.size
    print d2
    d2.set_primary('size')
    print d2

if __name__=="__main__":
    testing()
