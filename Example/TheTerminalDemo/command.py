#!/usr/bin/python
# -*- coding: UTF-8 -*-
import os,sys,re,json
# command.json

class Js(object):
    def __init__(self,ylj,jslj=None):
        if jslj is not None:
            os.chdir(jslj)
        self.wj = open('command.json','w')
        self.lj = ylj

    def __del__(self):
        self.wj.close()

    def mread(self):
        os.chdir(self.lj)
        ls = os.listdir(self.lj)
        ii = re.findall(r'(\w*Command).m',str(ls))
        return ii

    def save(self,hs):
        item = {}
        item["AllCommand"] = hs
        self.wj.write(json.dumps(item))

    def run(self):
        hs = self.mread()
        self.save(hs)

if __name__ == '__main__':
    ylj, jslj = sys.argv[1],sys.argv[2]
    js = Js(ylj, jslj)
    js.run()
