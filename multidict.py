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

    def __add_index(self, name, key_fun):
        if name in self._indices:
            raise IndexError('index %s already defined' % (name))
        idx = _index(self)

        if self._indices:
            # clone an existing index
            nam2 = self._indices.keys()[0]
            idx2 = getattr(self, 'by_'+nam2)
            for itm in idx2.values():
                idx.priv_set(key_fun(itm), itm)

        setattr(self, 'by_'+name, idx)
        self._indices[name] = key_fun

    def __setitem__(self, name, value):
        if not callable(value):
            raise ValueError('Index function is not callable')
        self.__add_index(name, value)

    def add(self, item):
        for name, fn in self._indices.iteritems():
            idx = getattr(self, 'by_'+name)
            idx.priv_set(fn(item), item)

    def remove(self, item):
        for name, fn in self._indices.iteritems():
            idx = getattr(self, 'by_'+name)
            idx.priv_del(fn(item))

    def __iter__(self):
        return self._indices.values().__iter__()

    def __delattr__(self, name):
        if name.startswith('by_'):
            del self._indices[name[3:]]
            object.__delattr__(self, name)
        else:
            return object.__delattr__(self, name)

def testing():
    d2 = multidict()

    class obj(object):
        def __init__(self, name, size):
            self.name = name
            self.size = size
        def __str__(self):
            return "<%s, %s>" % (self.name, self.size)

    d2['name'] = lambda x: x.name
    d2['size'] = lambda x: x.size

    d2.add(obj('bill', 3))
    d2.add(obj('jane', 100))

    for n, o in d2.by_name.iteritems():
        print "%s is %s" % (n, o)

    for s, o in d2.by_size.iteritems():
        print "%s is %s" % (s, o)

    for o in d2:
        print o

    del d2.by_name['bill']

    print "post deleting bill"

    for o in d2:
        print o

    del d2.by_size

    print d2._indices
    try:
        for s, o in d2.by_size.iteritems():
            print "%s is %s" % (s, o)
    except AttributeError, e:
        print e

if __name__=="__main__":
    testing()
