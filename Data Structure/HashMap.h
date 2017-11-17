/** @file */

#ifndef __HASHMAP_H
#define __HASHMAP_H

#include <iostream>
#include "ArrayList.h"
#include "ElementNotExist.h"

/**
 * HashMap is a map implemented by hashing. Also, the 'capacity' here means the
 * number of buckets in your internal implemention, not the current number of the
 * elements.
 *
 * Template argument H are used to specify the hash function.
 * H should be a class with a static function named ``hashCode'',
 * which takes a parameter of type K and returns a value of type int.
 * For example, the following class
 * @code
 *      class Hashint {
 *      public:
 *          static int hashCode(int obj) {
 *              return obj;
 *          }
 *      };
 * @endcode
 * specifies an hash function for integers. Then we can define:
 * @code
 *      HashMap<int, int, Hashint> hash;
 * @endcode
 *
 * Hash function passed to this class should observe the following rule: if two keys
 * are equal (which means key1 == key2), then the hash code of them should be the
 * same. However, it is not generally required that the hash function should work in
 * the other direction: if the hash code of two keys are equal, the two keys could be
 * different.
 *
 * Note that the correctness of HashMap should not rely on the choice of hash function.
 * This is to say that, even the given hash function always returns the same hash code
 * for all keys (thus causing a serious collision), methods of HashMap should still
 * function correctly, though the performance will be poor in this case.
 *
 * The order of iteration could be arbitary in HashMap. But it should be guaranteed
 * that each (key, value) pair be iterated exactly once.
 */
template <class K, class V, class H>
class HashMap
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
	const static int Mod = 999983;
	ArrayList<Entry> *list;
	int sz;
	static int hash(int x) {
		return x % Mod < 0 ? x % Mod + Mod : x % Mod;
	}

public:
    class Iterator
    {
		int current, i, j;
		HashMap<K, V, H> const *x;
    public:
		Iterator(HashMap<K, V, H> const *t) : x(t), i(0), j(0), current(0) {}
        /**
         * TODO Returns true if the iteration has more elements.
         */
        bool hasNext() {return current < x->sz;}

        /**
         * TODO Returns the next element in the iteration.
         * @throw ElementNotExist exception when hasNext() == false
         */
        const Entry &next() {
			if (!hasNext()) throw ElementNotExist("Iterator next");
			++ current;
			if (j == x->list[i].size()) {
				j = 0; ++ i;
				while (!x->list[i].size()) ++ i;
			}
			return x->list[i].get(j ++);
		}
    };

    /**
     * TODO Constructs an empty hash map.
     */
    HashMap() {sz = 0; list = new ArrayList<Entry>[Mod];}

    /**
     * TODO Destructor
     */
    ~HashMap() {clear(); delete [] list;}

    /**
     * TODO Assignment operator
     */
    HashMap &operator=(const HashMap &x) {
		if (list == x.list) return *this;
		clear();
		sz = x.sz;
		list = new ArrayList<Entry>[Mod];
		for (int i = 0; i < Mod; ++ i)
			list[i] = x.list[i];
		return *this;
	}

    /**
     * TODO Copy-constructor
     */
    HashMap(const HashMap &x) {
		sz = x.sz;
		list = new ArrayList<Entry>[Mod];
		for (int i = 0; i < Mod; ++ i)
			list[i] = x.list[i];
	}

    /**
     * TODO Returns an iterator over the elements in this map.
     */
    Iterator iterator() const {return Iterator(this);}

    /**
     * TODO Removes all of the mappings from this map.
     */
    void clear() {
		sz = 0;
		for (int i = 0; i < Mod; ++ i)
			list[i].clear();
	}

    /**
     * TODO Returns true if this map contains a mapping for the specified key.
     */
    bool containsKey(const K &key) const {
		int x = hash(H::hashCode(key));
		for (int i = 0; i < list[x].size(); ++ i)
			if (list[x].get(i).getKey() == key)
				return true;
		return false;
	}

    /**
     * TODO Returns true if this map maps one or more keys to the specified value.
     */
    bool containsValue(const V &value) const {
        for (int i = 0; i < Mod; ++ i)
            for (int j = 0; j < list[i].size(); ++ j)
                if (list[i].get(j).getValue() == value)
                    return true;
		return false;
	}

    /**
     * TODO Returns a const reference to the value to which the specified key is mapped.
     * If the key is not present in this map, this function should throw ElementNotExist exception.
     * @throw ElementNotExist
     */
    const V &get(const K &key) const {
		int x = hash(H::hashCode(key));
		for (int i = 0; i < list[x].size(); ++ i)
			if (list[x].get(i).getKey() == key)
				return list[x].get(i).getValue();
		throw ElementNotExist("get");
	}

    /**
     * TODO Returns true if this map contains no key-value mappings.
     */
    bool isEmpty() const {return !sz;}

    /**
     * TODO Associates the specified value with the specified key in this map.
     */
    void put(const K &key, const V &value) {
		int x = hash(H::hashCode(key));
		for (int i = 0; i < list[x].size(); ++ i)
			if (list[x].get(i).getKey() == key) {
				list[x].set(i, Entry(key, value));
				return;
			}
		list[x].add(Entry(key, value));
		++ sz;
	}

    /**
     * TODO Removes the mapping for the specified key from this map if present.
     * If there is no mapping for the specified key, throws ElementNotExist exception.
     * @throw ElementNotExist
     */
    void remove(const K &key) {
		int x = hash(H::hashCode(key));
		for (int i = 0; i < list[x].size(); ++ i)
			if (list[x].get(i).getKey() == key) {
				list[x].removeIndex(i);
				-- sz;
				return;
			}
		throw ElementNotExist("remove");
	}

    /**
     * TODO Returns the number of key-value mappings in this map.
     */
    int size() const {return sz;}
};

#endif
