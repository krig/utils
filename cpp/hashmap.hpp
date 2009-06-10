#ifndef __HASHMAP_HPP_KRIG_
#define __HASHMAP_HPP_KRIG_

#include <stdint.h>
// http://code.google.com/p/google-sparsehash/
#include <google/dense_hash_set>
#include <google/sparse_hash_set>
#include <google/dense_hash_map>
#include <google/sparse_hash_map>

#undef GET16BITS
#if (defined(__GNUC__) && defined(__i386__)) || defined(__WATCOMC__)	\
	|| defined(_MSC_VER) || defined (__BORLANDC__) || defined (__TURBOC__)
#define GET16BITS(d) (*((const uint16_t *) (d)))
#endif

#if !defined (GET16BITS)
#define GET16BITS(d) ((((uint32_t)(((const uint8_t *)(d))[1])) << 8)	\
		      +(uint32_t)(((const uint8_t *)(d))[0]) )
#endif

namespace krig
{
	// from http://www.azillionmonkeys.com/qed/hash.html
	inline uint32_t default_hash (const char * data, int len, uint32_t hash = 17) {
		uint32_t tmp;
		int rem;

		if (len <= 0 || data == NULL) return 0;

		rem = len & 3;
		len >>= 2;

		/* Main loop */
		for (;len > 0; len--) {
			hash  += GET16BITS (data);
			tmp    = (GET16BITS (data+2) << 11) ^ hash;
			hash   = (hash << 16) ^ tmp;
			data  += 2*sizeof (uint16_t);
			hash  += hash >> 11;
		}

		/* Handle end cases */
		switch (rem) {
		case 3: hash += GET16BITS (data);
			hash ^= hash << 16;
			hash ^= data[sizeof (uint16_t)] << 18;
			hash += hash >> 11;
			break;
		case 2: hash += GET16BITS (data);
			hash ^= hash << 11;
			hash += hash >> 17;
			break;
		case 1: hash += *data;
			hash ^= hash << 10;
			hash += hash >> 1;
		}

		/* Force "avalanching" of final 127 bits */
		hash ^= hash << 3;
		hash += hash >> 5;
		hash ^= hash << 4;
		hash += hash >> 17;
		hash ^= hash << 25;
		hash += hash >> 6;

		return hash;
	}

	inline size_t hashval(bool v) { return static_cast<size_t>(v); }
	inline size_t hashval(char v) { return static_cast<size_t>(v); }
	inline size_t hashval(unsigned char v) { return static_cast<size_t>(v); }
	inline size_t hashval(short v) { return static_cast<size_t>(v); }
	inline size_t hashval(int v) { return static_cast<size_t>(v); }
	inline size_t hashval(long v) { return static_cast<size_t>(v); }
	inline size_t hashval(unsigned short v) { return static_cast<size_t>(v); }
	inline size_t hashval(unsigned int v) { return static_cast<size_t>(v); }
	inline size_t hashval(unsigned long v) { return static_cast<size_t>(v); }
	inline size_t hashval(float v) { return static_cast<size_t>(v); }
	inline size_t hashval(double v) { return static_cast<size_t>(v); }
	inline size_t hashval(long double v) { return static_cast<size_t>(v); }

	template <typename T>
	size_t hashval(T* const& v) {
		std::size_t x = static_cast<std::size_t>(
			reinterpret_cast<std::ptrdiff_t>(v));
		return x + (x >> 3);
	}

	template <typename T>
	size_t hashval(const T* const& v) {
		std::size_t x = static_cast<std::size_t>(
			reinterpret_cast<std::ptrdiff_t>(v));
		return x + (x >> 3);
	}

	template< class T, unsigned N >
	size_t hashval(const T (&x)[N]) {
		return static_cast<size_t>(default_hash((const char*)x, sizeof(T)*N));
	}

	template< class T, unsigned N >
	size_t hashval(T (&x)[N]) {
		return static_cast<size_t>(default_hash((const char*)x, sizeof(T)*N));
	}

	inline size_t hashval(std::string const& v) {
		return static_cast<size_t>(default_hash(v.c_str(), v.length()+1));
	}

	inline size_t hashval(std::wstring const& v) {
		return static_cast<size_t>(default_hash((const char*)v.c_str(), (v.length()+1)*2));
	}

	template <class T>
	struct hash : public std::unary_function<T, size_t>
	{
		inline size_t operator()(T val) const {
			return static_cast<size_t>(default_hash(&val, sizeof(val)));
		}
	};

// Hash function specializations
	template <> struct hash<bool>;
	template <> struct hash<char>;
	template <> struct hash<unsigned char>;
	template <> struct hash<short>;
	template <> struct hash<int>;
	template <> struct hash<long>;
	template <> struct hash<unsigned short>;
	template <> struct hash<unsigned int>;
	template <> struct hash<unsigned long>;
	template <> struct hash<float>;
	template <> struct hash<double>;
	template <> struct hash<long double>;
	template<class T> struct hash<T* const&>;
	template <> struct hash<std::string>;
	template <> struct hash<std::wstring>;

#define KRIG_HASH_SPECIALIZE(type) \
	template <> struct hash<type>			 \
		: public std::unary_function<type, std::size_t> \
	{							\
		size_t operator()(type v) const			\
		{						\
			return krig::hashval(v);		\
		}						\
	};

	KRIG_HASH_SPECIALIZE(bool);
	KRIG_HASH_SPECIALIZE(char);
	KRIG_HASH_SPECIALIZE(unsigned char);
	KRIG_HASH_SPECIALIZE(short);
	KRIG_HASH_SPECIALIZE(int);
	KRIG_HASH_SPECIALIZE(long);
	KRIG_HASH_SPECIALIZE(unsigned short);
	KRIG_HASH_SPECIALIZE(unsigned int);
	KRIG_HASH_SPECIALIZE(unsigned long);
	KRIG_HASH_SPECIALIZE(float);
	KRIG_HASH_SPECIALIZE(double);
	KRIG_HASH_SPECIALIZE(long double);

	template <class T> struct hash<T*>
		: public std::unary_function<T*, std::size_t>
	{
		size_t operator()(T* v) const
		{
			return krig::hashval(v);
		}
	};

	template <> struct hash<std::string>
		: public std::unary_function<std::string, std::size_t>
	{
		size_t operator()(std::string const& v) const
		{
			return krig::hashval(v);
		}
	};

	template <> struct hash<std::wstring>
		: public std::unary_function<std::wstring, std::size_t>
	{
		size_t operator()(std::wstring const& v) const
		{
			return krig::hashval(v);
		}
	};

	struct str_eq
	{
		bool operator()(const char* s1, const char* s2) const
		{
			return (s1 == s2) || (s1 && s2 && strcmp(s1, s2) == 0);
		}
	};


	using google::dense_hash_map;
	using google::dense_hash_set;
	using google::sparse_hash_map;
	using google::sparse_hash_set;
}

/*
  usage example

  #include <iostream>
#include <google/dense_hash_map>

using google::dense_hash_map;      // namespace where class lives by default
using std::cout;
using std::endl;
using ext::hash;  // or __gnu_cxx::hash, or maybe tr1::hash, depending on your OS

struct eqstr
{
  bool operator()(const char* s1, const char* s2) const
  {
    return (s1 == s2) || (s1 && s2 && strcmp(s1, s2) == 0);
  }
};

int main()
{
  dense_hash_map<const char*, int, hash<const char*>, eqstr> months;
  
  months.set_empty_key(NULL);
  months["january"] = 31;
  months["february"] = 28;
  months["march"] = 31;
  months["april"] = 30;
  months["may"] = 31;
  months["june"] = 30;
  months["july"] = 31;
  months["august"] = 31;
  months["september"] = 30;
  months["october"] = 31;
  months["november"] = 30;
  months["december"] = 31;
  
  cout << "september -> " << months["september"] << endl;
  cout << "april     -> " << months["april"] << endl;
  cout << "june      -> " << months["june"] << endl;
  cout << "november  -> " << months["november"] << endl;
}

*/

#endif//__HASHMAP_HPP_KRIG_

