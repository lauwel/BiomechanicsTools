function qU = uminus(q)

qU = quaternion([-q.s -q.v]);
