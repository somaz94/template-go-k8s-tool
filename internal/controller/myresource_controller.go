package controller

import (
	"context"

	"k8s.io/apimachinery/pkg/runtime"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"

	myv1 "github.com/YOUR_USERNAME/YOUR_PROJECT/api/v1"
)

// MyResourceReconciler reconciles a MyResource object.
type MyResourceReconciler struct {
	client.Client
	Scheme *runtime.Scheme
}

// +kubebuilder:rbac:groups=YOUR_GROUP.YOUR_DOMAIN,resources=myresources,verbs=get;list;watch;create;update;patch;delete
// +kubebuilder:rbac:groups=YOUR_GROUP.YOUR_DOMAIN,resources=myresources/status,verbs=get;update;patch
// +kubebuilder:rbac:groups=YOUR_GROUP.YOUR_DOMAIN,resources=myresources/finalizers,verbs=update

// Reconcile handles MyResource reconciliation logic.
func (r *MyResourceReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	logger := log.FromContext(ctx)

	var resource myv1.MyResource
	if err := r.Get(ctx, req.NamespacedName, &resource); err != nil {
		return ctrl.Result{}, client.IgnoreNotFound(err)
	}

	logger.Info("reconciling", "name", resource.Name, "namespace", resource.Namespace)

	// TODO: Add your reconciliation logic here.

	return ctrl.Result{}, nil
}

// SetupWithManager sets up the controller with the Manager.
func (r *MyResourceReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&myv1.MyResource{}).
		Complete(r)
}
