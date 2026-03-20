package controller

import (
	"context"
	"testing"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/types"
	clientgoscheme "k8s.io/client-go/kubernetes/scheme"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client/fake"

	myv1 "github.com/YOUR_USERNAME/YOUR_PROJECT/api/v1"
)

func TestReconcile_NotFound(t *testing.T) {
	scheme := runtime.NewScheme()
	_ = clientgoscheme.AddToScheme(scheme)
	_ = myv1.AddToScheme(scheme)

	cl := fake.NewClientBuilder().WithScheme(scheme).Build()

	r := &MyResourceReconciler{
		Client: cl,
		Scheme: scheme,
	}

	req := ctrl.Request{
		NamespacedName: types.NamespacedName{
			Name:      "nonexistent",
			Namespace: "default",
		},
	}

	_, err := r.Reconcile(context.Background(), req)
	if err != nil {
		t.Errorf("Reconcile() error = %v, want nil for not found", err)
	}
}

func TestReconcile_Found(t *testing.T) {
	scheme := runtime.NewScheme()
	_ = clientgoscheme.AddToScheme(scheme)
	_ = myv1.AddToScheme(scheme)

	resource := &myv1.MyResource{
		ObjectMeta: metav1.ObjectMeta{
			Name:      "test-resource",
			Namespace: "default",
		},
		Spec: myv1.MyResourceSpec{
			Replicas: 3,
			Message:  "hello",
		},
	}

	cl := fake.NewClientBuilder().WithScheme(scheme).WithObjects(resource).Build()

	r := &MyResourceReconciler{
		Client: cl,
		Scheme: scheme,
	}

	req := ctrl.Request{
		NamespacedName: types.NamespacedName{
			Name:      "test-resource",
			Namespace: "default",
		},
	}

	_, err := r.Reconcile(context.Background(), req)
	if err != nil {
		t.Errorf("Reconcile() error = %v, want nil", err)
	}
}
