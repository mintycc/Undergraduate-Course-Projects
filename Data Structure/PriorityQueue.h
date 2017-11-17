/** @file */
#ifndef __PRIORITYQUEUE_H
#define __PRIORITYQUEUE_H

#include "ArrayList.h"
#include "LinkedList.h"
#include "ElementNotExist.h"
#include "Less.h"

/**
 * This is a priority queue based on a priority priority queue. The
 * elements of the priority queue are ordered according to their
 * natual ordering (operator<), or by a Comparator provided as the
 * second template parameter.
 * The head of this queue is the least element with respect to the
 * specified ordering (different from C++ STL).
 * The iterator does not return the elements in any particular order.
 * But it is required that the iterator will eventually return every
 * element in this queue (even if removals are performed).
 */

template <class V, class C = Less<V> >
class PriorityQueue
{
	struct Node {
        int height;
		V value;
		Node *ch[2], *father;

		Node(const V &x, Node *n) : value(x) {
			ch[0] = ch[1] = father = n;
			height = 1;
		}

		Node() {}

		bool findFather() {return father->ch[1] == this;}
	} *null, *root;

    C cmp;
	int sz;

	Node *merge(Node *u, Node *v) {
		if (u == null) return v;
		if (v == null) return u;
		if (cmp(v->value, u->value)) swap(u, v);
		u->ch[1] = merge(u->ch[1], v);
		u->ch[1]->father = u;
		if (u->ch[0]->height < u->ch[1]->height)
			swap(u->ch[0], u->ch[1]);
		u->height = u->ch[1]->height + 1;
		return u;
	}
public:
    class Iterator
    {
		ArrayList<Node *> list;
		PriorityQueue<V, C> &x;
		bool pre;
		int current;
    public:
		Iterator(PriorityQueue<V, C> &x) : x(x), pre(false), current(0) {
			if (x.empty()) return;
			list.add(x.root);
			for (int i = 0; i < list.size(); ++ i) {
				if (list.get(i)->ch[0] != x.null)
					list.add(list.get(i)->ch[0]);
				if (list.get(i)->ch[1] != x.null)
					list.add(list.get(i)->ch[1]);
			}
		}
        /**
         * TODO Returns true if the iteration has more elements.
         */
        bool hasNext() {return current < list.size();}

        /**
         * TODO Returns the next element in the iteration.
         * @throw ElementNotExist exception when hasNext() == false
         */
        const V &next() {
			if (!hasNext()) throw ElementNotExist("Iterator next");
			pre = true;
			return list.get(current ++)->value;
		}

		/**
		 * TODO Removes from the underlying collection the last element
		 * returned by the iterator.
		 * The behavior of an iterator is unspecified if the underlying
		 * collection is modified while the iteration is in progress in
		 * any way other than by calling this method.
		 * @throw ElementNotExist
		 */
		void remove() {
			if (!pre) throw ElementNotExist("Iterator remove");
			pre = false;
			Node *cur = list.get(current - 1);
			Node *tmp = x.merge(cur->ch[0], cur->ch[1]);
			if (cur == x.root) {
				if (tmp != x.null) {
					x.root = tmp;
					x.root->father = x.null;
				} else x.root = x.null;
			} else {
				bool d = cur->findFather();
				cur->father->ch[d] = tmp;
				tmp->father = cur->father;
			}
			delete cur;
			-- x.sz;
		}
    };

    /**
     * TODO Constructs an empty priority queue.
     */
    PriorityQueue() {
		null = new Node();
		null->ch[0] = null->ch[1] = null->father = null;
		null->height = 0;
		sz = 0;
		root = null;
	}

    /**
     * TODO Destructor
     */
    ~PriorityQueue() {clear(); delete null;}

    /**
     * TODO Assignment operator
     */
    PriorityQueue &operator=(const PriorityQueue &x) {
		clear();
		if (x.size()) {
            ArrayList<Node *> list;
            list.add(x.root);
            for (int i = 0; i < list.size(); ++ i) {
                if (list.get(i)->ch[0] != x.null)
                    list.add(list.get(i)->ch[0]);
                if (list.get(i)->ch[1] != x.null)
                    list.add(list.get(i)->ch[1]);
                push(list.get(i)->value);
            }
            return *this;
		}
	}

    /**
     * TODO Copy-constructor
     */
    PriorityQueue(const PriorityQueue &x) {
		null = new Node();
		null->ch[0] = null->ch[1] = null->father = null;
		null->height = 0;
		sz = 0;
		root = null;
		if (x.empty()) return;
		ArrayList<Node *> list;
		list.add(x.root);
		for (int i = 0; i < list.size(); ++ i) {
			if (list.get(i)->ch[0] != x.null)
				list.add(list.get(i)->ch[0]);
			if (list.get(i)->ch[1] != x.null)
				list.add(list.get(i)->ch[1]);
			push(list.get(i)->value);
		}
	}

	/**
	 * TODO Initializer_list-constructor
	 * Constructs a priority queue over the elements in this Array List.
     * Requires to finish in O(n) time.
	 */
	PriorityQueue(const ArrayList<V> &x) {
		null = new Node();
		null->ch[0] = null->ch[1] = null->father = null;
		null->height = 0;
		sz = 0;
		root = null;

		LinkedList<Node *> list;
		for (int i = 0; i < x.size(); ++ i)
			list.add(new Node(x.get(i), null));
		while (list.size() > 1) {
			Node *a = list.getFirst();
			list.removeFirst();
			Node *b = list.getFirst();
			list.removeFirst();
			list.add(merge(a, b));
		}
		root = list.getFirst();
		sz = x.size();
	}

    /**
     * TODO Returns an iterator over the elements in this priority queue.
     */
    Iterator iterator() {return Iterator(*this);}

    /**
     * TODO Removes all of the elements from this priority queue.
     */
    void clear() {
		if (empty()) return;
		ArrayList<Node *> list;
		list.add(root);
		for (int i = 0; i < list.size(); ++ i) {
			if (list.get(i)->ch[0] != null)
				list.add(list.get(i)->ch[0]);
			if (list.get(i)->ch[1] != null)
				list.add(list.get(i)->ch[1]);
			Node *tmp = list.get(i);
			delete tmp;
		}
		root = null;
		sz = 0;
	}

    /**
     * TODO Returns a const reference to the front of the priority queue.
     * If there are no elements, this function should throw ElementNotExist exception.
     * @throw ElementNotExist
     */
    const V &front() const {
		if (empty()) throw ElementNotExist("front");
		return root->value;
	}

    /**
     * TODO Returns true if this PriorityQueue contains no elements.
     */
    bool empty() const {return !sz;}

    /**
     * TODO Add an element to the priority queue.
     */
    void push(const V &value) {
		++ sz;
		Node *tmp = new Node(value, null);
		(root = merge(root, tmp))->father = null;
	}

    /**
     * TODO Removes the top element of this priority queue if present.
     * If there is no element, throws ElementNotExist exception.
     * @throw ElementNotExist
     */
    void pop() {
		if (empty()) throw ElementNotExist("pop");
		root = merge(root->ch[0], root->ch[1]);
		if (-- sz) root->father = null;
	}

    /**
     * TODO Returns the number of key-value mappings in this map.
     */
    int size() const {return sz;}
};

#endif
