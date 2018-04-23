(ns test
  (:require [clojure.string :as string]
            [clojure.java.shell :refer [sh]]))

(defn- split-at-pipe [s] (string/split s #"\|"))
(defn- split-at-space [s] (string/split s #" "))

(defn- trim-space [v] (remove #(= "" %) v))
(defn- is-resolvable? [o] (resolve (symbol o)))

(defn- wrap-shell-call [l] `(get (sh ~@l) :out))

(defn- symbolify-or-typify [l] (if (is-resolvable? (first l))
                                (map read-string l)
                                (wrap-shell-call l)))

(defn parse-piped-string [s]
  (let [instructions (split-at-pipe s)]
    (map (comp
          symbolify-or-typify
          trim-space
          split-at-space)
         instructions)))

(defmacro pc [str-body]
  "This macro reads a string bash-like command and convert it into clojure-like syntax
  for example the String : + 2 2 | inc | range 1 | clojure.string/join
  gets converted into : (range 1 (inc (+ 2 2))) ...and get executed ofc"
  (cons '->> (parse-piped-string str-body)))
