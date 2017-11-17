/** @file */
#ifndef __TREEMAP_H
#define __TREEMAP_H

#include <cstdlib>
#include "ElementNotExist.h"

/**
 * TreeMap is the balanced-tree implementation of map. The iterators must
 * iterate through the map in the natural order (operator<) of the key.
 */
template<class K, class V>
class TreeMap
{
public:
    class Entry
    {
        K key;
        V value;
    public:
        Entry(K k, V v)
        {
            key = k;
            value = v;
        }

        const K& getKey() const
        {
            return key;
        }

        const V& getValue() const
        {
            return value;
        }
    };

private:
	struct Node {
		Entry *data;
		int size, keyp;
		Node *ch[2];
		Node(Entry *p, Node *n) : data(p) {
			ch[0] = ch[1] = n;
			size = 1;
			keyp = rand() - 1;
		}
		void update() {
			size = ch[0]->size + ch[1]->size + 1;
		}
	} *root, *null;

	void rotate(Node *&t, bool d) {
		Node *ch = t->ch[d];
		t->ch[d] = ch->ch[!d];
		ch->ch[!d] = t;
		t->update(); ch->update();
		t = ch;
	}

	void insert(Node *&t, Entry *x) {
		if (t == null) {
			t = new Node(x, null);
			return;
		}
		if (t->data->getKey() == x->getKey()) {
			delete t->data;
			t->data = x;
			return;
		}
		bool d = t->data->getKey() < x->getKey();
		insert(t->ch[d], x);
		if (t->ch[d]->keyp < t->keyp)
			rotate(t, d);
		else t->update();
	}

	void Delete(Node *&t, K x) {
		if (t == null) return;
		if (t->data->getKey() == x) {
			bool d = t->ch[1]->keyp < t->ch[0]->keyp;
			if (t->ch[d] == null) {
                delete t->data;
				delete t;
				t = null;
				return;
			}
			rotate(t, d);
			Delete(t->ch[!d], x);
		} else {
			bool d = t->data->getKey() < x;
			Delete(t->ch[d], x);
		}
		t->update();
	}

	void clear(Node *&t) {
		if (t != null) {
			clear(t->ch[0]);
			clear(t->ch[1]);
			delete t->data;
			delete t;
			t = null;
		}
	}

	void copy(Node *t, Node *n) {
		if (t != n) {
			put(t->data->getKey(), t->data->getValue());
			copy(t->ch[0], n);
			copy(t->ch[1], n);
		}
	}

	bool findKey(Node *t, const K &key) const {
		if (t == null) return false;
		if (t->data->getKey() == key) return true;
		bool d = t->data->getKey() < key;
		return findKey(t->ch[d], key);
	}

	bool findValue(Node *t, const V &value) const {
		if (t == null) return false;
		if (t->data->getValue() == value) return true;
		return findValue(t->ch[0], value) || findValue(t->ch[1], value);
	}

	const V &find(Node *t, const K &key) const {
		if (t->data->getKey() == key)
			return t->data->getValue();
		bool d = t->data->getKey() < key;
		return find(t->ch[d], key);
	}

public:
    class Iterator
    {
		int current;
		const TreeMap<K, V> &tree;
		Node *t;
    public:
		Iterator(const TreeMap<K, V> &x) : current(0), tree(x), t(x.null) {}
        /**
         * TODO Returns true if the iteration has more elements.
         */
        bool hasNext() {return current < tree.root->size;}

        /**
         * TODO Returns the next element in the iteration.
         * @throw ElementNotExist exception when hasNext() == false
         */
        const Entry &next() {
			if (!hasNext()) throw ElementNotExist("Iterator next");
			int k = ++ current;
			for (t = tree.root; t->ch[0]->size + 1 != k;)
				if (t->ch[0]->size + 1 < k) {
					k -= t->ch[0]->size + 1;
					t = t->ch[1];
				} else t = t->ch[0];
			return *t->data;
		}
    };

    /**
     * TODO Constructs an empty tree map.
     */
    TreeMap() {
		null = new Node(0, 0);
		null->size = 0;
		null->keyp = ~0U >> 1;
		root = null;
	}

    /**
     * TODO Destructor
     */
    ~TreeMap() {clear(); delete null;}

    /**
     * TODO Assignment operator
     */
    TreeMap &operator=(const TreeMap &x) {
		if (root == x.root) return *this;
		clear();
		null = new Node(0, 0);
		null->size = 0;
		null->keyp = ~0U >> 1;
		root = null;
		copy(x.root, x.null);
		return *this;
	}

    /**
     * TODO Copy-constructor
     */
    TreeMap(const TreeMap &x) {
		null = new Node(0, 0);
		null->size = 0;
		null->keyp = ~0U >> 1;
		root = null;
		copy(x.root, x.null);
	}

    /**
     * TODO Returns an iterator over the elements in this map.
     */
    Iterator iterator() const {return Iterator(*this);}

    /**
     * TODO Removes all of the mappings from this map.
     */
    void clear() {clear(root);}

    /**
     * TODO Returns true if this map contains a mapping for the specified key.
     */
    bool containsKey(const K &key) const {return findKey(root, key);}

    /**
     * TODO Returns true if this map maps one or more keys to the specified value.
     */
    bool containsValue(const V &value) const {return findValue(root, value);}

    /**
     * TODO Returns a const reference to the value to which the specified key is mapped.
     * If the key is not present in this map, this function should throw ElementNotExist exception.
     * @throw ElementNotExist
     */
    const V &get(const K &key) const {
		if (!findKey(root, key))
			throw ElementNotExist("get");
		return find(root, key);
	}

    /**
     * TODO Returns true if this map contains no key-value mappings.
     */
    bool isEmpty() const {return !root->size;}

    /**
     * TODO Associates the specified value with the specified key in this map.
     */
    void put(const K &key, const V &value) {insert(root, new Entry(key, value));}

    /**
     * TODO Removes the mapping for the specified key from this map if present.
     * If there is no mapping for the specified key, throws ElementNotExist exception.
     * @throw ElementNotExist
     */
    void remove(const K &key) {
		if (!findKey(root, key))
			throw ElementNotExist("remove");
		Delete(root, key);
	}

    /**
     * TODO Returns the number of key-value mappings in this map.
     */
    int size() const {return root->size;}
};

#endif
